module UNBIT
# To change this template, choose Tools | Templates
# and open the template in the editor.
class Domain < ActiveResource::Base
   self.site = "https://rest.unbit.it/"
   self.user = "interact"
   self.password = "Fy176ar4"
   self.ssl_options = {:verify_mode  => OpenSSL::SSL::VERIFY_NONE}
   self.format = :json

   def processes
     pp = UNBIT::Process.find :all
     pp.select {|process| process.domain_id.to_i == id}
   end
   def master_processes
     return processes.select {|p| p.master? }.first
   rescue Exception => ex
     puts ex.message
     nil
   end

end
end
