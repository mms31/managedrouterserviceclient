require 'rubygems'
require 'net/ssh'
require 'net/telnet'
require 'cisco/common'
require 'cisco/telnet'
require 'cisco/ssh'
require 'cisco/base'
require 'json'
require 'net/http'
require 'uri'
require 'rest-client'


class String
  def is_number?
    true if Float(self) rescue false
  end
end


def uploadLineToDeviceManager(deviceid,numberOfLine,configLine)
	#Upload config to Device Manager
	RestClient.post "http://127.0.0.1:3000/configlines.json",{ 'router_id' => '1','linenumber' => numberOfLine, 'lineconfig' => configLine  }.to_json, :content_type => :json
	
end

def configToDatabase(config)
	#Function puts config into database
        puts config
	#Seperate out line by line 
	configline = config.split( /\r?\n/ )
	configline.each do | cl |
		linenumber = 0
		splitline = cl.split(":")
		splitline.each do | sl |
			puts (sl.strip)
			if sl.strip.is_number?
				#puts "Is a number"
				linenumber = sl.strip
			else
				uploadLineToDeviceManager('1',linenumber,sl.strip)
			end
		end
	end
end

#
#Agruments
#User ARGV[0]
#Password ARGV[1]
host = ARGV[0]
user = ARGV[1]
password = ARGV[2]
#

cisco = Cisco::Base.new(:host => "#{host}", :user => 'michael', :password => 'michael', :transport => :ssh)
#cisco.cmd("sh ver")
cisco.cmd("terminal length 0")
cisco.cmd("show running-config linenum")
output = cisco.run
#puts output

output.each do | o |
	#look for "show running-config linenum"
	puts o.slice!(0..26)
        runningconfigstring = o.slice!(0..8).strip 
	puts "(" + runningconfigstring + ")"
	if runningconfigstring.eql? 'Building'
		puts "Found Config"
		configToDatabase(o)
	end
end



