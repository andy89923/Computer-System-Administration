#!/bin/sh

if $UPLOAD_VUSER = "ftp"; then
        echo `date`: Anonymous has upload file $1 with size $UPLOAD_SIZE >> /var/log/uploadscript.log;
else
        echo `date`: $UPLOAD_VUSER has upload file $1 with size $UPLOAD_SIZE >> /var/log/uploadscript.log;
fi