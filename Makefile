# must be absolute path
CATOP = $(PWD)/ca
# see https://gist.github.com/4570053 for sample ca.conf
CACONF = $(CATOP)/../ca.conf

OPENSSL = openssl
DAYS = -days 3652
CADAYS = -days 3652
REQ = $(OPENSSL) req -config $(CACONF)
CA = $(OPENSSL) ca -config $(CACONF)
VERIFY = $(OPENSSL) verify
X509 = $(OPENSSL) x509

CA_CERT_REQ_FILE = $(CATOP)/reqs/ca.csr
CA_CERT_KEY_FILE = $(CATOP)/private/ca.key
CA_CERT_FILE = $(CATOP)/certs/ca.crt

SUBCA_CERT_REQ_FILE = $(CATOP)/reqs/subca.csr
SUBCA_CERT_KEY_FILE = $(CATOP)/private/subca.key
SUBCA_CERT_FILE = $(CATOP)/certs/subca.crt

CRL_LINK = $(CATOP)/crl/crl.pem
CRL_FILE = $(CATOP)/crl/crl$(shell cat $(CATOP)/crlnumber).pem

ifneq '$(NAME)' ''
	CERT_REQ_FILE = $(CATOP)/reqs/$(NAME).csr
	CERT_KEY_FILE = $(CATOP)/private/$(NAME).key
	CERT_FILE = $(CATOP)/certs/$(NAME).crt
else
	CERT_REQ_FILE = $(CATOP)/reqs/new.csr
	CERT_KEY_FILE = $(CATOP)/private/new.key
	CERT_FILE = $(CATOP)/certs/new.crt
endif

.SUFFIXES: .pem .crt .p12
.PHONY: init careq cacert req cert verify revoke clean

help:
	@echo "Makefile.CA manages your OpenSSL CA"
	@echo ""
	@echo "init   - Create & initialize ca directory."
	@echo "careq  - Create certificate request of CA."
	@echo "cacert - Sign certificate request of CA."
	@echo "subcareq  - Create certificate request of Subortinate (Issuing) CA."
	@echo "subcacert - Sign certificate request of Subortinate (Issuing) CA."
	@echo "req    - Create certificate request."
	@echo "cert   - Sign specified certificate request."
	@echo "verify - Verify specified certificate."
	@echo "revoke - Revoke specified certificate."
	@echo "crl    - Generate CRL."
	@echo ""
	@echo "Configuration:"
	@echo "CATOP:  $(CATOP)"
	@echo "CACONF: $(CACONF)"

debug:
	@echo "CATOP:  $(CATOP)"
	@echo "CACONF: $(CACONF)"
	@echo "NAME: $(NAME)"
	@echo "CERT_REQ_FILE: $(CERT_REQ_FILE)"
	@echo "CERT_KEY_FILE: $(CERT_KEY_FILE)"
	@echo "CERT_FILE:     $(CERT_FILE)"

.pem.crt:
	$(X509) -in $< -out $@

.pem.p12:
	$(OPENSSL) pkcs12 -export -clcerts -in $< -inkey $(CERT_KEY_FILE) -out $@

init: $(CATOP) $(CATOP)/crlnumber $(CACONF)

## CA config file
$(CACONF):
	@echo "NOTE: You will want to create $(CACONF)"
	@false

## Creating new CA
$(CATOP):
	@echo "Creating new CA directory"
	mkdir -m 755 $(CATOP)
	mkdir -m 755 $(CATOP)/reqs
	mkdir -m 755 $(CATOP)/certs
	mkdir -m 755 $(CATOP)/crl
	mkdir -m 755 $(CATOP)/newcerts
	mkdir -m 700 $(CATOP)/private
	echo "00" > $(CATOP)/serial
	touch $(CATOP)/index.txt
	$(MAKE) $(CATOP)/crlnumber
	$(MAKE) $(CACONF)

careq: $(CATOP) $(CA_CERT_REQ_FILE)

$(CA_CERT_REQ_FILE): $(CA_CERT_KEY_FILE)
	chmod 600 $(CA_CERT_REQ_FILE)
$(CA_CERT_KEY_FILE):
	$(REQ) -new -keyout $(CA_CERT_KEY_FILE) \
		-out $(CA_CERT_REQ_FILE) \
		$(NULL)
	chmod 600 $(CA_CERT_KEY_FILE)

cacert: careq
	$(MAKE) $(CA_CERT_FILE)

$(CA_CERT_FILE): $(CA_CERT_REQ_FILE)
	$(CA) -out $(CA_CERT_FILE) $(CADAYS) -batch \
		-keyfile $(CA_CERT_KEY_FILE) -selfsign \
		-extensions v3_ca \
		-infiles $(CA_CERT_REQ_FILE) \
		$(NULL)
	chmod 644 $(CA_CERT_FILE)


subcareq: $(CATOP) $(SUBCA_CERT_REQ_FILE)

$(SUBCA_CERT_REQ_FILE): $(SUBCA_CERT_KEY_FILE)
	chmod 600 $(SUBCA_CERT_REQ_FILE)
$(SUBCA_CERT_KEY_FILE):
	$(REQ) -new -keyout $(SUBCA_CERT_KEY_FILE) \
		-out $(SUBCA_CERT_REQ_FILE) \
		$(NULL)
	chmod 600 $(SUBCA_CERT_KEY_FILE)

subcacert: subcareq
	$(MAKE) $(SUBCA_CERT_FILE)

$(SUBCA_CERT_FILE): $(SUBCA_CERT_REQ_FILE)
	$(CA) -out $(SUBCA_CERT_FILE) $(CADAYS) -batch \
		-keyfile $(SUBCA_CERT_KEY_FILE) -selfsign \
		-extensions v3_ca \
		-infiles $(SUBCA_CERT_REQ_FILE) \
		$(NULL)
	chmod 644 $(SUBCA_CERT_FILE)

req: $(CATOP)
	$(MAKE) $(CERT_KEY_FILE)
	$(MAKE) $(CERT_REQ_FILE)

$(CERT_REQ_FILE):
	chmod 600 $(CERT_REQ_FILE)
$(CERT_KEY_FILE):
	$(REQ) -new -nodes -keyout $(CERT_KEY_FILE) -out $(CERT_REQ_FILE) $(DAYS)
	chmod 600 $(CERT_KEY_FILE)

cert: $(CERT_REQ_FILE)
	$(MAKE) $(CERT_FILE)
	@echo -e '\033[1;32mCertificate: $(CERT_FILE)\033[0m'

$(CERT_FILE): $(CERT_REQ_FILE)
	$(CA) -out $(CERT_FILE) -infiles $(CERT_REQ_FILE)
	chmod 644 $(CERT_FILE)

verify: $(CERT_FILE)
	$(VERIFY) -CAfile $(CA_CERT_FILE) $(CERT_FILE)

revoke: $(CERT_FILE)
	$(CA) -revoke $(CERT_FILE)
	$(MAKE) crl

crl:
	$(MAKE) $(CRL_FILE)
	ln -sf $(CRL_FILE) $(CRL_LINK)
	@echo -ne '\033[1;32m'
	@echo -n  'CRL is in $(CRL_FILE).'
	@echo -ne '\033[0m\n'

$(CRL_FILE): $(CATOP)/crlnumber
	$(CA) -gencrl -out $(CRL_FILE)
	chmod 644 $(CRL_FILE)

$(CATOP)/crlnumber:
	echo 01 > $@

clean:
	$(RM) \
		$(CERT_REQ_FILE) \
		$(CERT_KEY_FILE) \
		$(CERT_FILE) \
		$(SUBCERT_REQ_FILE) \
		$(SUBCERT_KEY_FILE) \
		$(SUBCERT_FILE) \
		$(NULL)

