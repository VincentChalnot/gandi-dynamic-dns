# gandi-dynamic-dns
Updates gandi.net records when the external IP of the system has changed.

Usage :
```bash
$ GANDI_LIVEDNS_API_KEY=xxxxxx \
  PUSHOVER_TOKEN=xxxxx \ # Optional
  PUSHOVER_USER_KEY=xxxxx \ # Optional
  ~/update_dns_records.sh
```

Check script for further details
