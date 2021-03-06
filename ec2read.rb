class Ec2read

  require 'pp'
  $values = [  "Valid search attributes are:",
               :aki,
               :ami,
               :az,
               :default,
               :ebs,
               :errata_f,
               :ex_ip,
               :fqdn,
               :in_ip,
               :intern,
               :paravirt,
               :sgs,
               :size,
               :state,
               :tags,
               :uuid_az,
               :xen
            ]

  $needed = [
             :AWS_ACCESS_KEY,
             :AWS_ACCESS_KEY,
             :AWS_AUTO_SCALING_HOME,
             :AWS_CLOUDFORMATION_HOME,
             :AWS_CREDENTIAL_FILE,
             :AWS_ELB_HOME,
             :AWS_IAM_HOME,
             :AWS_SECRET_KEY,
             :EC2_CERT,
             :EC2_HOME,
             :EC2_PRIVATE_KEY,
             :JAVA_HOME
            ]


  def initialize(file = nil)
    ec2in = readin(file) if file
    ec2in ||= ec2din
    @ec2in = gethash(ec2in)
  end

  def readin(file)
    File.open(file,"r").read
  end

  def gethash(contents)
    if contents.nil?
      puts "Error: Nil passed to #{__method__}"
      exit 2
    end

    contents.each_line.inject({}) do |results, line|
      l = line.split("\t")
      case l.first
        #when "RESERVATION"
        #   "reservation"3
      when "INSTANCE"
        results[l[1]] = {
          :ami => l[2],
          :fqdn => l[3],
          :intern => l[4],
          :state => l[5],
          :size => l[9],
          :az => l[11],
          :aki => l[12],
          :ex_ip => l[16],
          :in_ip => l[17],
          :ebs => l[20],
          :paravirt => l[25],
          :xen => l[26],
          :uuid_az => l[27],
          :sgs => l[28],
          :default => l[29],
          :errata_f => l[30] }
        results[:last_instance] = l[1] # Save for blockdevice.
      when "BLOCKDEVICE"
        results[:last_instance] = { :volid => l[2], :date => l[3] }
      when "TAG"
        results[l[2]][:tags] ||= {}
        results[l[2]][:tags][l[3]] = l[4]
      end
      results
    end
  end

  def self.testh(file)
    require 'pp'
    fd = readin(file)
    myhash = gethash(fd)
    pp myhash.first
  end

  def ec2din
    require 'verifyenv'
    if %x{which ec2-describe-instances}.nil?
      puts "Unable to find ec2-describe-instances in path!"
      exit 2
    end
    gethash(%{ec2-describe-instances})
  end

  def to_hash
    @ec2in
  end

  def find_by_tag(tag,value)
    @ec2in.select do |k,v|
      v[:tags] && v[:tags][tag] && v[:tags][tag].strip == value
    end
  end

  def find_by_attr(attr,value)
    if attr.to_s.empty? or value.to_s.empty?
      $values.each { |v| puts v }
      exit
    end
    @ec2in.select do |i,r|
      r[attr.to_sym] == value
    end
  end
end
