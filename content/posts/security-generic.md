---
title: "[outdated] Information security in generic"
date: 2017-11-17T19:50:55+03:00
type: post
comments: true
categories: ["thoughts"]
tags: ["security"]
---

Some very generic thoughts about informational security.

<!--more-->

| WARNING |
|---------|
| UPD. This article is outdated | 

The topic is very complicated, but the scope of the subject will be described only in generics.

This list is not standard or something. 

It's more like marks on fields...

## Generic

v 0.02

![](/images/security-generic/susp.jpg)

* Be **suspicious** and **don't trust anything** on words, especially tools with "Secure" in their name; - REMARK: Of course questions of trust and trustworthiness - are more complicated and deserve additional posts, but the main thing - is to be curious, ask questions and don't believe in "perfect security by design";

![](/images/security-generic/cyberrisks.png)

* **Create good readable documentation** for your information security perimeter, technologies, and security vectors, to make it possible correctly understand **risks** ; Always work under describing security vectors and vulnerabilities from your technological stack; Remember that this is forever continuous process and should be started not after a security breach as a reaction, but as pre-action (be pro-active);

![](/images/security-generic/firewall1.jpg)

![](/images/security-generic/firewall.gif)

* **Firewall** should be enabled with white list policy rules and automated;

![](/images/security-generic/hole.png)

* **Fix known vulnerabilities;** Keep in mind that in the military in some cases destroying sensitive vulnerable objects by tactical missile strike will also make it secure from an information security point of view; In civil places - business, managers, developers, or operations - can be against changing something that "works" - they are not your enemies; They just work in another scope of tasks and don't see it from your angle;

![](/images/security-generic/server-room.gif)
![](/images/security-generic/map.png)

* Good understandable and readable **documentation** with a description of **zones of responsibilities** of all team players including third side members from an information security point of view will help you understand the scope of your work and make it better (Simply - **who** will do this and that); Keep it updated if some new system or team member has appeared;

![](/images/security-generic/document.png)

* Documentation for application layer with full **source code** available (with all included libraries and dependencies) - is key to passing internal code audit; It's not everything that's required, but no source code - no audit/automated testing possible; Of course, fans of proprietary software will tell that we can just trust IT giant's, as there are huge reputation risks for them, but look at item number one from this list;

![](/images/security-generic/simple.jpg)

* [Kerckhoffs principle](https://en.wikipedia.org/wiki/Kerckhoffs%27s_principle) recommends using open implementation rather than closed or especially obfuscated; Security by obfuscation can't work well where is: 1- lots of time or 2- human factor;

![](/images/security-generic/corruption.jpg)

* **Human factor** can be minimized by access roles and limited privileges access according to requirements. Use the [principle of least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege);



* **[IDS](https://en.wikipedia.org/wiki/Intrusion_detection_system)** (same as [DLP](https://en.wikipedia.org/wiki/Data_loss_prevention_software) and [WAF](https://en.wikipedia.org/wiki/Web_application_firewall)) have different tasks than regular service monitoring; That's why it should be under different [SLA](https://en.wikipedia.org/wiki/Service-level_agreement) / hardware / people from the very beginning;



![](/images/security-generic/isolate.png)

* **Isolate items;** Level of isolation for every peace should be according to system design requirements which should be defined according to the risks model and technical requirements; For example: on level 1 - permissions/ owner isolation (...) and 9 - physical isolation on different hardware / vendor in different data-center); 

![](/images/security-generic/selinux.png)

* **[MAC](https://en.wikipedia.org/wiki/Mandatory_access_control)/[RBAC](https://en.wikipedia.org/wiki/Role-based_access_control)** better to be enabled with white list policy rules and automated;

![](/images/security-generic/vv.jpg)

* Perform external, internal, and code/application level **security audits** on regular basis; 


![](/images/security-generic/attackvectors.jpg)

* **Minimize attack vectors;** If you can avoid using some software, library, hardware, or technology - do it;
* **Minimize attack vectors again;** If you have software, library, hardware, or technology that you don't use or need now, but was needed earlier - remove it from production;



![](/images/security-generic/password.png)

* **Passwords/keys keep/recovery/renew documentation** will explain what is password manager, what to do when you lost your password/laptop, accidentally commit in public GIT your/corporate private keys - how to change them quickly and how to use them; Here is good [article](https://www.troyhunt.com/passwords-evolved-authentication-guidance-for-the-modern-era/) with some recommendations and [OWASP cheat sheet](https://www.owasp.org/index.php/Password_Storage_Cheat_Sheet);


![](/images/security-generic/backup1.jpg)

* **Regular backups** should be **automated** and **monitored**;
* **Regular backups** should be **tested** and configured according to your SLA with proper [RPO](https://en.wikipedia.org/wiki/Recovery_point_objective) and [RTO](https://en.wikipedia.org/wiki/Recovery_time_objective);


![](/images/security-generic/backup3.jpg)

* **Offline encrypted backups** can make it possible to perform extra changes audit even if they can be useless from a business point of view in long term;


* Subordinatively and Financial - The information security department is **not** a part of developers, operations or DevOps teams, or any others - if you want them to do their job good;



![](/images/security-generic/encrypt.png)

* Use **communication encryption** for external systems according to your information security model (VPNs and transport layer encryption should be checked to be strong enough on regular basis);
* Use **storage encryption** according to your information security model;



![](/images/security-generic/denied.jpg)

* **White list** is a better security strategy than black list, but of course requires more resources; For any new software, library, or technology default level access policy should be "denied" (file level access, networking, system calls, etc.);


## Conclusion

![](/images/security-generic/cat.png)

* Information security will **not** come to you from called "secure" magic boxes like antivirus software, firewalls, or any others even if they are very good;
* I.S. can be represented as exponentially growing complicity multiplied by all weaknesses of all your systems over time;
* One exploitable vulnerability on the production live system can be enough to ruin everything and destroy your business or even life; 
* The main role of I.S. department / specialists - is to be in charge of process controlling, identifying risks, and minimizing possible impact;
* On the other side - there is nothing perfect in this world and no 100% guarantee that even if everything was built correctly that's security-related incidents will not appear. You can be only definitely sure - the probability of huge issues decreased and the possible impact was minimized;

## Links

* [Github - awesome security](https://github.com/sbilly/awesome-security)
* [Github - awesome security gist](https://github.com/Hack-with-Github/Awesome-Security-Gists)
* [OWASP - top 10](https://www.owasp.org/index.php/Category:OWASP_Top_Ten_Project)
* [RHEL - security guide](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/pdf/Security_Guide/Red_Hat_Enterprise_Linux-6-Security_Guide-en-US.pdf)
* [Wikipedia - Information Security](https://en.wikipedia.org/wiki/Information_security)
* [Wikipedia - Cyber security standards](https://en.wikipedia.org/wiki/Cyber_security_standards)
* [Archlinux wiki - Security](https://wiki.archlinux.org/index.php/security)
* [CEH](https://www.eccouncil.org/programs/certified-ethical-hacker-ceh/)
* [Passwords-evolved-article](https://www.troyhunt.com/passwords-evolved-authentication-guidance-for-the-modern-era/)
* [OWASP-passwords-cheat-sheet](https://www.owasp.org/index.php/Password_Storage_Cheat_Sheet)
