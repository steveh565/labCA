# labCA
Simple Lab CA automation

Usage:
 make init;
 make cacert;
 make subcacert;


Example output:

make init:
```
        steveh@FLD-L-00029460:~/code/labCA$ make init
        cat: /home/steveh/code/labCA/ca/crlnumber: No such file or directory
        Creating new CA directory
        mkdir -m 755 /home/steveh/code/labCA/ca
        mkdir -m 755 /home/steveh/code/labCA/ca/reqs
        mkdir -m 755 /home/steveh/code/labCA/ca/certs
        mkdir -m 755 /home/steveh/code/labCA/ca/crl
        mkdir -m 755 /home/steveh/code/labCA/ca/newcerts
        mkdir -m 700 /home/steveh/code/labCA/ca/private
        echo "00" > /home/steveh/code/labCA/ca/serial
        touch /home/steveh/code/labCA/ca/index.txt
        make /home/steveh/code/labCA/ca/crlnumber
        make[1]: Entering directory '/mnt/c/Users/hillier/OneDrive - F5 Networks/code/labCA'
        cat: /home/steveh/code/labCA/ca/crlnumber: No such file or directory
        echo 01 > /home/steveh/code/labCA/ca/crlnumber
        make[1]: Leaving directory '/mnt/c/Users/hillier/OneDrive - F5 Networks/code/labCA'
        make /home/steveh/code/labCA/ca/../ca.conf
        make[1]: Entering directory '/mnt/c/Users/hillier/OneDrive - F5 Networks/code/labCA'
        make[1]: '/home/steveh/code/labCA/ca/../ca.conf' is up to date.
        make[1]: Leaving directory '/mnt/c/Users/hillier/OneDrive - F5 Networks/code/labCA'
```

make cacert:
```
        steveh@FLD-L-00029460:~/code/labCA$ make cacert
        openssl req -config /home/steveh/code/labCA/ca/../ca.conf -new -keyout /home/steveh/code/labCA/ca/private/ca.key \
                -out /home/steveh/code/labCA/ca/reqs/ca.csr \

        Generating a RSA private key
        ................................+++++
        ..........................+++++
        writing new private key to '/home/steveh/code/labCA/ca/private/ca.key'
        Enter PEM pass phrase:
        Verifying - Enter PEM pass phrase:
        -----
        You are about to be asked to enter information that will be incorporated
        into your certificate request.
        What you are about to enter is what is called a Distinguished Name or a DN.
        There are quite a few fields but you can leave some blank
        For some fields there will be a default value,
        If you enter '.', the field will be left blank.
        -----
        Country Name (2 letter code) [US]:CA
        State or Province Name (full name) [California]:Ontario
        Locality Name (eg, city) [San Francisco]:Ottawa
        Organization Name (eg, company) [MyCompany]:SSC
        Organizational Unit Name (e.g., section) []:DCN
        Common Name (e.g. server FQDN) []:SSC-DCN Root Certificate Authority
        chmod 600 /home/steveh/code/labCA/ca/private/ca.key
        chmod 600 /home/steveh/code/labCA/ca/reqs/ca.csr
        make /home/steveh/code/labCA/ca/certs/ca.crt
        make[1]: Entering directory '/mnt/c/Users/hillier/OneDrive - F5 Networks/code/labCA'
        openssl ca -config /home/steveh/code/labCA/ca/../ca.conf -out /home/steveh/code/labCA/ca/certs/ca.crt -days 3652 -batch \
                -keyfile /home/steveh/code/labCA/ca/private/ca.key -selfsign \
                -extensions v3_ca \
                -infiles /home/steveh/code/labCA/ca/reqs/ca.csr \

        Using configuration from /home/steveh/code/labCA/ca/../ca.conf
        Enter pass phrase for /home/steveh/code/labCA/ca/private/ca.key:
        Can't open ./ca/index.txt.attr for reading, No such file or directory
        139695711523264:error:02001002:system library:fopen:No such file or directory:../crypto/bio/bss_file.c:72:fopen('./ca/index.txt.attr','r')
        139695711523264:error:2006D080:BIO routines:BIO_new_file:no such file:../crypto/bio/bss_file.c:79:
        Check that the request matches the signature
        Signature ok
        Certificate Details:
                Serial Number: 0 (0x0)
                Validity
                    Not Before: Mar 12 14:38:28 2020 GMT
                    Not After : Mar 12 14:38:28 2030 GMT
                Subject:
                    countryName               = CA
                    stateOrProvinceName       = Ontario
                    organizationName          = SSC
                    organizationalUnitName    = DCN
                    commonName                = SSC-DCN Root Certificate Authority
                X509v3 extensions:
                    X509v3 Basic Constraints: critical
                        CA:TRUE
                    X509v3 Subject Key Identifier:
                        F3:F4:F8:1E:0F:90:3A:F1:DC:BE:2F:7B:53:FC:52:95:C0:42:79:03
                    X509v3 Authority Key Identifier:
                        keyid:F3:F4:F8:1E:0F:90:3A:F1:DC:BE:2F:7B:53:FC:52:95:C0:42:79:03
                        DirName:/C=CA/ST=Ontario/O=SSC/OU=DCN/CN=SSC-DCN Root Certificate Authority
                        serial:00

                    X509v3 Key Usage: critical
                        Digital Signature, Non Repudiation, Key Encipherment, Key Agreement, Certificate Sign, CRL Sign
                    X509v3 Extended Key Usage: critical
                        Code Signing, E-mail Protection
        Certificate is to be certified until Mar 12 14:38:28 2030 GMT (3652 days)

        Write out database with 1 new entries
        Data Base Updated
        chmod 644 /home/steveh/code/labCA/ca/certs/ca.crt
        make[1]: Leaving directory '/mnt/c/Users/hillier/OneDrive - F5 Networks/code/labCA'
```

make subcacert:
```
        steveh@FLD-L-00029460:~/code/labCA$ make subcacert
        openssl req -config /home/steveh/code/labCA/ca/../ca.conf -new -keyout /home/steveh/code/labCA/ca/private/subca.key \
                -out /home/steveh/code/labCA/ca/reqs/subca.csr \

        Generating a RSA private key
        ...............+++++
        .............................................................+++++
        writing new private key to '/home/steveh/code/labCA/ca/private/subca.key'
        Enter PEM pass phrase:
        Verifying - Enter PEM pass phrase:
        -----
        You are about to be asked to enter information that will be incorporated
        into your certificate request.
        What you are about to enter is what is called a Distinguished Name or a DN.
        There are quite a few fields but you can leave some blank
        For some fields there will be a default value,
        If you enter '.', the field will be left blank.
        -----
        Country Name (2 letter code) [US]:CA
        State or Province Name (full name) [California]:Ontario
        Locality Name (eg, city) [San Francisco]:Ottawa
        Organization Name (eg, company) [MyCompany]:SSC
        Organizational Unit Name (e.g., section) []:DCN
        Common Name (e.g. server FQDN) []:SSC-DCN SubCA certificate
        chmod 600 /home/steveh/code/labCA/ca/private/subca.key
        chmod 600 /home/steveh/code/labCA/ca/reqs/subca.csr
        make /home/steveh/code/labCA/ca/certs/subca.crt
        make[1]: Entering directory '/mnt/c/Users/hillier/OneDrive - F5 Networks/code/labCA'
        openssl x509 -req -in /home/steveh/code/labCA/ca/reqs/subca.csr \
                -CA /home/steveh/code/labCA/ca/certs/ca.crt -CAkey /home/steveh/code/labCA/ca/private/ca.key \
                -extensions v3_ca -days 365 -CAcreateserial \
                -out /home/steveh/code/labCA/ca/certs/subca.crt \

        Signature ok
        subject=C = CA, ST = Ontario, L = Ottawa, O = SSC, OU = DCN, CN = SSC-DCN SubCA certificate
        Getting CA Private Key
        Enter pass phrase for /home/steveh/code/labCA/ca/private/ca.key:
        chmod 644 /home/steveh/code/labCA/ca/certs/subca.crt
        make[1]: Leaving directory '/mnt/c/Users/hillier/OneDrive - F5 Networks/code/labCA'
```