# crowdfounding

This collection of scripts and config files may help putting in place a system to record the evolution of a crowdfounding project (e.g. Kickstarter, Ulule).

It's not a system that will directly help you detect events in the project, like EB liberation.
It's rather like Kictracker, but with a temporal granularity as fine as you wish (e.g. every 5 min).

As of now, I haven't (yet) made any effort to make the system easily re-usable.
So you need to hack a bit by yourself.

## Technical prerequisites (in the current state)

### For realtime recording of information:
- **bash** shell script interpreter
- **curl** command line utility, to send HTTP requests at Kickstarter or Ulule
- **jq** command line utility, to extract useful information from the response sent back by Kickstarter or Ulule
- **logstash** deamon to inject data in the database
- **Elasticsearch 2** database

### For data exploration:
- **Kibana 3**
- or **R**

### Operating System

- developed under **Mac OSX**
- should work as is under **Linux**
- might require some minor adaptations for **Windows**
