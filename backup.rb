require 'aws-sdk'  
require 'digest/md5'


#Define as credenciais de acesso ao S3.
Aws.config.update({
   credentials: Aws::Credentials.new('AKIAJMLMV25KHDUF4S3A', 'tCj/tCgVrCDTBZsERdAv84QPhTDnujmwv5A0fScu')
})

region = 'us-east-1'
s3 = Aws::S3::Resource.new(region: region)


# Bucket para onde serão enviados os logs
bucket_name = 'sre-inloco'

# Coleta todos os arquivos de Log dentro do diretório padrão do Nginx
logs = Dir.glob('/var/log/nginx/*.*')
#logs = Dir.glob('/home/etc/SRE/*.{txt}')

#Nome do arquivo auxiliar utilizado para armazenar os hashes de cada arquivo de log
file_list = "list"

#Criar arquivo list, caso não exista ainda.
if File.exists?(file_list)
    puts "Lista de hashs já existe"
else
    File.new("list",  "a+")
end


# Checa alterações nos arquivos comparando o hash atual com a lista de hashes 
# no arquivo auxiliar(list)
i = 0
while i < logs.length

  name = File.basename logs[i]
  
  # Gera o Hash atual do arquivo usando o nome do arquivo e o seu conteúdo
  full_hash = Digest::MD5.new
  file_hash = Digest::MD5.hexdigest(logs[i])
  hash = Digest::MD5.hexdigest(File.read(logs[i]))
  full_hash.update file_hash
  full_hash.update hash
  
  # Checa se o hash atual já está no arquivo auxiliar(list)
  if File.foreach(file_list).grep(/#{full_hash}/).any?
    
    # Se o hash já estiver no arquivo auxiliar, significa que o arquivo atual 
    # não foi alterado.
    
    puts "O arquivo #{name} não foi alterado..."

  else

    # Se o hash não estiver no arquivo auxiliar, adiciona o hash no arquivo e envia
    # o arquivo para o S3.

    puts "Mudança identificada no arquivo #{name}."  
    file = File.open(file_list,"a+")
    file.puts full_hash
    file.close
    obj = s3.bucket(bucket_name).object(name)
    obj.upload_file(logs[i])
    puts "Arquivo enviado para o S3: #{name}"
  end

  
  i += 1
end


