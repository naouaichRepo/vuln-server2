WL=~/wordlists/wordlists/discovery/common.txt

ffuf -w $WL -w $WL \
  -u https://lab-f0fbf17db5034bad.zerodayacademy.com/FUZZ_FUZZ2 \
  -t 50 \
  -rate-limit 100 \
  -timeout 10 \
  -mc 200,301 \
  -o ffuf_fuzz_fuzz.json -of json