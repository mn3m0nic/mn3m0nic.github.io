---
title: "Patching Zabbix server housekeeping function"
date: 2017-10-27T12:00:00+03:00
type: post
comments: true
categories: ["practice"]
tags: ["MySQL", "Zabbix", "zabbix-server", "patch"]
---

Here we have an alternative fix for the Zabbix-server housekeeping function.

| WARNING |
|---------|
| Solution is outdated and compatible only with Zabbix server 2.4.x |

# Problem statement

1. Zabbix server 2.4.5 has very aggressive housekeeping.

2. Without housekeeping you will suffer from out of disk space very soon.

3. With high load and housekeeping enabled Zabbix server time to time can be unresponsive to any requests.


As the weak point is DB good solutions can be in the next options:

1. [MySQL partitioning](https://dev.mysql.com/doc/refman/5.7/en/partitioning.html)
2. Reduce the load of data on the Zabbix-server
3. Scale up your hardware (MySQL disk and RAM)
4. Increate DB performance by app or FS tuning (caching)
5. _Patch for Zabbix-server to have less aggressive housekeeping_



# Description


* Applicable to Zabbix-server 2.4.x (Tested on 2.4.5)
* You will start the Housekeeper thread by sending a USR1 signal and stop it via USR2 using your regular cron (it will allow you to make all work at night or at a specific time, for example);
* All DELETE database requests started from the HK thread for the trends table now will have LIMIT **HistoryDeleteLimit**; 
* After removing **HistoryAndTrendsDeleteBeforeSleep** records HK will go to sleep on **HistoryAndTrendsSleepBetweenDeletes** ms;
* All of these should/can make your HK work smoother and database blocking time should be minimized;
* Current version of patch v0.01 (check for newer versions);

# Zabbix server new variables

| Configuration Variable      | Description   | Default value  |
| --------------------------- |---------------|:--------------:|
| HistoryAndTrendsDeleteBeforeSleep |Count of records that must be deleted before the housekeeper will go to sleep. This value is related only to the cleanup function of History and Trends (as most heavy functions) | 1000000 (records) |
| HistoryAndTrendsSleepBetweenDeletes | Seconds for sleep before deletes. It's just time for which thread of housekeeper to halt execution and wait until when the database performs previous queries. Must be less than MySQL connection timeout. | 10 (s) |
| HistoryDeleteLimit  | SQL LIMIT for every delete - additional limit which can minimize the impact of cleaning "heavy" items | 1000 (records) |


# Recommendations before applying

* Don't use this patch if there is any way to minimize the data amount collected / processed by the Zabbix server;
* Monitor database size time by time and records count in trends; 

# Сomparison

* Housekeeper of health man (before the patch):

![before](https://raw.githubusercontent.com/mn3m0nic/ffts/master/zabbix-server-patch/before_HK.png "before")

* Housekeeper of smoking man (applied):

![after](https://raw.githubusercontent.com/mn3m0nic/ffts/master/zabbix-server-patch/after_HK.png "after1")


# Download patch:

- [src](https://raw.githubusercontent.com/mn3m0nic/ffts/master/zabbix-server-patch/zabbix-2.4.5-housekeeper-nice.patch)


# Patch inline:

```patch

--- zabbix-2.4.5.orig/src/zabbix_server/housekeeper/housekeeper.c	2015-04-22 10:56:00.000000000 +0300
+++ zabbix-2.4.5/src/zabbix_server/housekeeper/housekeeper.c	2017-03-14 02:55:39.571005720 +0300
@@ -149,6 +149,31 @@
 	{NULL}
 };
 
+unsigned char flag_start;
+unsigned char flag_abort;
+
+/******************************************************************************
+ *                                                                            *
+ * Function: sig_handler                                                      *
+ *                                                                            *
+ * function handle UNIX signals and change flags according to the next rules:     *
+ *   USR1 -> flag_start=1 -> HK will start                                    *
+ *   USR2 -> flag_abort=1 -> HK will abort only if it is working in cleaning     *
+ *                           history or trends (!)                            *
+ *                                                                            *
+ ******************************************************************************/
+
+void sig_handler(int signo){
+  switch(signo) {
+    case SIGUSR1:
+      flag_start=1; flag_abort=0;
+      break;
+    case SIGUSR2:
+      flag_start=0; flag_abort=1;
+      break;
+  }
+}
+
 /******************************************************************************
  *                                                                            *
  * Function: hk_item_update_cache_compare                                     *
@@ -468,11 +493,13 @@
 {
 	const char		*__function_name = "housekeeping_history_and_trends";
 
+        int                     hk_deleted_history_and_trends = 0;  // Counter of deleted records before sleep
 	int			deleted = 0, i, rc;
 	zbx_hk_history_rule_t	*rule;
 
 	zabbix_log(LOG_LEVEL_DEBUG, "In %s() now:%d", __function_name, now);
-
+        zabbix_log(LOG_LEVEL_DEBUG, "[HK] HK deletes before sleep = %d", CONFIG_HISTORY_AND_TRENDS_DELETE_BEFORE_SLEEP);
+        zabbix_log(LOG_LEVEL_DEBUG, "[HK] HK sleep after delete = %d", CONFIG_HISTORY_AND_TRENDS_SLEEP_BETWEEN_DELETES);
 	/* prepare delete queues for all history housekeeping rules */
 	hk_history_delete_queue_prepare_all(hk_history_rules, now);
 
@@ -488,11 +515,28 @@
 		for (i = 0; i < rule->delete_queue.values_num; i++)
 		{
 			zbx_hk_delete_queue_t	*item_record = rule->delete_queue.values[i];
+                        zabbix_log(LOG_LEVEL_DEBUG, "[SQL] delete from %s where itemid=" ZBX_FS_UI64 " and clock<%d limit %d", rule->table, item_record->itemid, item_record->min_clock, 
+                            CONFIG_HISTORY_DELETE_LIMIT);
 
-			rc = DBexecute("delete from %s where itemid=" ZBX_FS_UI64 " and clock<%d",
-					rule->table, item_record->itemid, item_record->min_clock);
+			rc = DBexecute("delete from %s where itemid=" ZBX_FS_UI64 " and clock<%d limit %d",
+					rule->table, item_record->itemid, item_record->min_clock,
+                                        CONFIG_HISTORY_DELETE_LIMIT);
 			if (ZBX_DB_OK < rc)
 				deleted += rc;
+                        hk_deleted_history_and_trends += rc;
+                        if (hk_deleted_history_and_trends > CONFIG_HISTORY_AND_TRENDS_DELETE_BEFORE_SLEEP) {
+                          zabbix_log(LOG_LEVEL_WARNING, "[housekeeping_history_and_trends] deleted %d => go to sleep on %d s", hk_deleted_history_and_trends, CONFIG_HISTORY_AND_TRENDS_SLEEP_BETWEEN_DELETES);
+                          zbx_sleep_loop(CONFIG_HISTORY_AND_TRENDS_SLEEP_BETWEEN_DELETES);
+                          hk_deleted_history_and_trends=0;
+                        }
+                        else {
+                          zabbix_log(LOG_LEVEL_DEBUG, "[DEBUG] rule for sleep was not actioned [%d < %d]", hk_deleted_history_and_trends, CONFIG_HISTORY_AND_TRENDS_DELETE_BEFORE_SLEEP);
+                        }
+                        if (flag_abort) {
+                           flag_abort=0;
+                           zabbix_log(LOG_LEVEL_WARNING, "[DEBUG] Aborting routine due USR2 signal");
+                           break;
+                        }
 		}
 
 		/* clear history rule delete queue so it's ready for the next housekeeping cycle */
@@ -528,7 +572,8 @@
 	int		keep_from, deleted = 0;
 	int		rc;
 
-	zabbix_log(LOG_LEVEL_DEBUG, "In %s() table:'%s' filter:'%s' min_clock:%d now:%d",
+
+	zabbix_log(LOG_LEVEL_WARNING, "In %s() table:'%s' filter:'%s' min_clock:%d now:%d",
 			__function_name, rule->table, rule->filter, rule->min_clock, now);
 
 	/* initialize min_clock with the oldest record timestamp from the database */
@@ -790,13 +835,19 @@
 	zabbix_log(LOG_LEVEL_INFORMATION, "%s #%d started [%s #%d]", get_daemon_type_string(daemon_type),
 			server_num, get_process_type_string(process_type), process_num);
 
-	zbx_setproctitle("%s [startup idle for %d minutes]", get_process_type_string(process_type),
-			HOUSEKEEPER_STARTUP_DELAY);
+	zbx_setproctitle("%s [startup idle until USR1]", get_process_type_string(process_type));
 
-	zbx_sleep_loop(HOUSEKEEPER_STARTUP_DELAY * SEC_PER_MIN);
+        flag_start=0;
+        flag_abort=0;
+        signal(SIGUSR1, sig_handler);
+        signal(SIGUSR2, sig_handler);
 
 	for (;;)
 	{
+                while(!flag_start) {
+                       zbx_sleep_loop(10);
+                }
+                flag_start=0;
 		zabbix_log(LOG_LEVEL_WARNING, "executing housekeeper");
 		now = time(NULL);
 
@@ -827,16 +878,18 @@
 		sec = zbx_time() - sec;
 
 		zabbix_log(LOG_LEVEL_WARNING, "%s [deleted %d hist/trends, %d items, %d events, %d sessions, %d alarms,"
-				" %d audit items in " ZBX_FS_DBL " sec, idle %d hour(s)]",
+				" %d audit items in " ZBX_FS_DBL " sec, idle until USR1 signal]",
 				get_process_type_string(process_type), d_history_and_trends, d_cleanup, d_events,
-				d_sessions, d_services, d_audit, sec, CONFIG_HOUSEKEEPING_FREQUENCY);
+				d_sessions, d_services, d_audit, sec);
 		DBclose();
 
 		zbx_setproctitle("%s [deleted %d hist/trends, %d items, %d events, %d sessions, %d alarms, %d audit "
-				"items in " ZBX_FS_DBL " sec, idle %d hour(s)]",
+				"items in " ZBX_FS_DBL " sec, idle until signal]",
 				get_process_type_string(process_type), d_history_and_trends, d_cleanup, d_events,
-				d_sessions, d_services, d_audit, sec, CONFIG_HOUSEKEEPING_FREQUENCY);
+				d_sessions, d_services, d_audit, sec);
 
-		zbx_sleep_loop(CONFIG_HOUSEKEEPING_FREQUENCY * SEC_PER_HOUR);
+                zbx_sleep_loop(60);
+                flag_start=0; // Clearing flags if signal USR1 received when the function was in progress;
+                flag_abort=0; // Clearing flags if signal USR2 received when the function was in progress;
 	}
 }
--- zabbix-2.4.5.orig/src/zabbix_server/housekeeper/housekeeper.h	2015-04-22 10:56:00.000000000 +0300
+++ zabbix-2.4.5/src/zabbix_server/housekeeper/housekeeper.h	2017-03-03 18:04:48.832803529 +0300
@@ -24,6 +24,9 @@
 
 extern int	CONFIG_HOUSEKEEPING_FREQUENCY;
 extern int	CONFIG_MAX_HOUSEKEEPER_DELETE;
+extern int      CONFIG_HISTORY_AND_TRENDS_DELETE_BEFORE_SLEEP;
+extern int      CONFIG_HISTORY_AND_TRENDS_SLEEP_BETWEEN_DELETES;
+extern int      CONFIG_HISTORY_DELETE_LIMIT;
 
 ZBX_THREAD_ENTRY(housekeeper_thread, args);
 
--- zabbix-2.4.5.orig/src/zabbix_server/server.c	2015-04-22 10:56:00.000000000 +0300
+++ zabbix-2.4.5/src/zabbix_server/server.c	2017-03-03 18:10:45.496812662 +0300
@@ -141,6 +141,10 @@
 int	CONFIG_HISTSYNCER_FREQUENCY	= 5;
 int	CONFIG_CONFSYNCER_FORKS		= 1;
 int	CONFIG_CONFSYNCER_FREQUENCY	= 60;
+int     CONFIG_HISTORY_AND_TRENDS_DELETE_BEFORE_SLEEP   = 1000000;
+int     CONFIG_HISTORY_AND_TRENDS_SLEEP_BETWEEN_DELETES = 10;
+int     CONFIG_HISTORY_DELETE_LIMIT     = 1000;
+
 
 int	CONFIG_VMWARE_FORKS		= 0;
 int	CONFIG_VMWARE_FREQUENCY		= 60;
@@ -479,6 +483,12 @@
 			PARM_OPT,	1,			24},
 		{"MaxHousekeeperDelete",	&CONFIG_MAX_HOUSEKEEPER_DELETE,		TYPE_INT,
 			PARM_OPT,	0,			1000000},
+                {"HistoryAndTrendsDeleteBeforeSleep", &CONFIG_HISTORY_AND_TRENDS_DELETE_BEFORE_SLEEP,
+                  TYPE_INT, PARM_OPT,   0,                     10000000},
+                {"HistoryAndTrendsSleepBetweenDeletes", &CONFIG_HISTORY_AND_TRENDS_SLEEP_BETWEEN_DELETES,
+                  TYPE_INT,  PARM_OPT,  0,                        10000},
+                {"HistoryDeleteLimit",          &CONFIG_HISTORY_DELETE_LIMIT,
+                  TYPE_INT,  PARM_OPT,  0,                      1000000},
 		{"SenderFrequency",		&CONFIG_SENDER_FREQUENCY,		TYPE_INT,
 			PARM_OPT,	5,			SEC_PER_HOUR},
 		{"TmpDir",			&CONFIG_TMPDIR,				TYPE_STRING,

```

