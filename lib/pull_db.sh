#!/bin/bash

function LastBackupName () { 
  # heroku pgbackups -a wisr-questionbase | tail -n 50 | head -3 | tail -n 1 | cut -d" " -f 1
  heroku pgbackups -a wisr-questionbase | tail -n 1 | cut -d" " -f 1
}

heroku pgbackups -a wisr-questionbase >&2

heroku pgbackups:capture -a wisr-questionbase >&2
new_backup=$(LastBackupName)
curl $(heroku pgbackups:url -a wisr-questionbase $new_backup) > temporary_backup.dump

old_backup=$(LastBackupName)
heroku pgbackups:destroy -a wisr-questionbase $old_backup >&2

pg_restore --verbose --clean --no-acl --no-owner -h localhost -U qb -d qb temporary_backup.dump 
rm -f temporary_backup.dump

heroku pgbackups -a wisr-questionbase >&2