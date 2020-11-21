ps -cul 75233 | sed 1d | awk -F' ' '{
                        print "USER:", $1, "\nPID:", $2, "\nPPID:", $13;
                        print "STAT:", $8, "\n%CPU:", $3, "\n%MEM:", $4;
                        print "COMMAND:", $11;
                }'
