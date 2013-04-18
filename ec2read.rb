class Ec2read


  def initialize(instance_dump)

  end


  def self.readin(file)
    File.open(file,"r").read
  end

  def self.gethash(contents)
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
        results[l[1]] = { :ami => l[2], :fqdn => l[3], :intern => l[4], :state => l[5], :size => l[9], :az => l[11], :aki => l[12], :ex_ip => l[16], :in_ip => l[17], :ebs => l[20], :paravirt => l[25], :xen => l[26], :uuid_az => l[27], :sgs => l[28], :default => l[29], :errata_f => l[30] }
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

  def self.doit(file)
    gethash(readin(file))
  end

  def self.ec2in
    if %x{which ec2-describe-instances}.nil?
      puts "Unable to find ec2-describe-instances in path!"
      exit 2
    end
    gethash(%{ec2-describe-instances})
  end


  def instance(instance_id,hash)

  end



  def find(field,filter)


  end




end
