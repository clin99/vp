set -e
for path in ./benchmark/*; do 
  /usr/bin/time -f "\t%E real,\t%U user,\t%S sys" ./verilog_parser $path
#   printf "$path\n"
#   dirname="$(basename "${path}")"
#   file="$path/$dirname.v"
#   printf "$file\n"
done
