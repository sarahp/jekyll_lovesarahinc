local   = ARGV[0]
s3_dest = ARGV[1]

if local == nil || s3_dest == nil 
  puts "syntax aws_cf_sync.rb local_source s3_dest"
  exit
end

config = "#{Dir.pwd}/_scripts/s3.config"
if !File.exists?(config)
  puts "please setup your s3.config file"
  exit
end

invalidate = "#{Dir.pwd}/_scripts/aws_cf_invalidate.rb"
if !File.exists?(invalidate)
  puts "please download the aws_cf_invalidate.rb script"
  exit
end

s3_dest   = s3_dest.split('/')
s3_bucket = s3_dest.shift
s3_path   = s3_dest.join('/')

s3_path += '/' unless s3_dest.length == 0

%x[ $(which s3cmd) -c #{config} sync #{local} s3://#{s3_bucket}/#{s3_path} --acl-public ]

files = %x[ cd _site && find . -type f ].split("\n").map do |f| 
  s3_path + f[2,f.length]
end

%x[ ruby #{invalidate} #{files.join(' ')} ]