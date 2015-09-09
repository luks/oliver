require 'openssl'
require 'pry'

CERT_PATH='ssl/'

pass_phrase = 'oliver'

key = OpenSSL::PKey::RSA.new 2048
open CERT_PATH + 'private_key.pem', 'w' do |io| io.write key.to_pem end
open CERT_PATH + 'public_key.pem', 'w' do |io| io.write key.public_key.to_pem end



#cipher = OpenSSL::Cipher.new 'AES-128-CBC'
#key_secure = key.export cipher, pass_phrase

#open CERT_PATH + 'private.secure.pem', 'w' do |io|
#  io.write key_secure
#end



# key2 = OpenSSL::PKey::RSA.new File.read CERT_PATH + 'private_key.pem'
# key2.public? # => true

# key3 = OpenSSL::PKey::RSA.new File.read CERT_PATH + 'public_key.pem'
# key3.private? # => false

# key4_pem = File.read CERT_PATH + 'private.secure.pem'
# key4 = OpenSSL::PKey::RSA.new key4_pem, pass_phrase

#data = [['C', 'Czech'],['L', 'Prague'],['O', 'Latoto'],['CN', 'oliver'],['DC', 'IT']]



#name = OpenSSL::X509::Name.parse data
name = OpenSSL::X509::Name.parse 'CN=oliver/DC=server/C=CZ/L=Prague/O=Latoto/DC=IT'

cert = OpenSSL::X509::Certificate.new
cert.version = 2
cert.serial = 0
cert.not_before = Time.now
cert.not_after = Time.now + 36000000
cert.public_key = key.public_key
cert.subject = name
cert.issuer = name
cert.sign key, OpenSSL::Digest::SHA256.new

open CERT_PATH + 'certificate.pem', 'w' do |io| io.write cert.to_pem end

extension_factory = OpenSSL::X509::ExtensionFactory.new nil, cert
cert.add_extension extension_factory.create_extension('basicConstraints', 'CA:FALSE', true)
cert.add_extension extension_factory.create_extension('keyUsage', 'keyEncipherment,dataEncipherment,digitalSignature')
cert.add_extension extension_factory.create_extension('subjectKeyIdentifier', 'hash')

# cert2 = OpenSSL::X509::Certificate.new File.read 'certificate.pem'


cipher = OpenSSL::Cipher::Cipher.new 'AES-128-CBC'
open CERT_PATH + 'ca_key.pem', 'w', 0400 do |io|
  io.write key.export(cipher, pass_phrase)
end


ca_key = OpenSSL::PKey::RSA.new 2048

ca_name = name

ca_cert = OpenSSL::X509::Certificate.new
ca_cert.serial = 0
ca_cert.version = 2
ca_cert.not_before = Time.now
ca_cert.not_after = Time.now + 8640000

ca_cert.public_key = ca_key.public_key
ca_cert.subject = ca_name
ca_cert.issuer = ca_name

extension_factory = OpenSSL::X509::ExtensionFactory.new
extension_factory.subject_certificate = ca_cert
extension_factory.issuer_certificate = ca_cert

ca_cert.add_extension extension_factory.create_extension('subjectKeyIdentifier', 'hash')
ca_cert.add_extension extension_factory.create_extension('basicConstraints', 'CA:TRUE', true)
ca_cert.add_extension extension_factory.create_extension('keyUsage', 'cRLSign,keyCertSign', true)

ca_cert.sign ca_key, OpenSSL::Digest::SHA256.new

open CERT_PATH + 'ca_cert.pem', 'w' do |io|
  io.write ca_cert.to_pem
end


csr = OpenSSL::X509::Request.new
csr.version = 0
csr.subject = name
csr.public_key = key.public_key
csr.sign key, OpenSSL::Digest::SHA256.new


open CERT_PATH + 'csr.pem', 'w' do |io|
  io.write csr.to_pem
end

csr_cert = OpenSSL::X509::Certificate.new
csr_cert.serial = 0
csr_cert.version = 2
csr_cert.not_before = Time.now
csr_cert.not_after = Time.now + 600

csr_cert.subject = csr.subject
csr_cert.public_key = csr.public_key
csr_cert.issuer = ca_cert.subject

extension_factory = OpenSSL::X509::ExtensionFactory.new
extension_factory.subject_certificate = csr_cert
extension_factory.issuer_certificate = ca_cert

csr_cert.add_extension extension_factory.create_extension('basicConstraints', 'CA:FALSE')
csr_cert.add_extension extension_factory.create_extension('keyUsage', 'keyEncipherment,dataEncipherment,digitalSignature')
csr_cert.add_extension extension_factory.create_extension('subjectKeyIdentifier', 'hash')
csr_cert.sign ca_key, OpenSSL::Digest::SHA256.new

open CERT_PATH + 'csr_cert.pem', 'w' do |io|
  io.write csr_cert.to_pem
end

# #openssl genrsa -des3 -out server.key 1024
# #openssl req -new -key server.key -out server.csr
# #openssl x509 -req -days 1024 -in server.csr -signkey server.key -out server.crt


# Create a private key and then generate a certificate request from it:

#  openssl genrsa -out key.pem 2048
#  openssl req -new -key key.pem -out req.pem
# The same but just using req:

#  openssl req -newkey rsa:2048 -keyout key.pem -out req.pem
# Generate a self signed root certificate:

#  openssl req -x509 -newkey rsa:2048 -keyout key.pem -out req.pem

# Check csr
# openssl req -text -in csr.pem -noout

binding.pry
