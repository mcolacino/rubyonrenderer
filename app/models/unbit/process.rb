module UNBIT
# To change this template, choose Tools | Templates
# and open the template in the editor.
class Process < ActiveResource::Base
   self.site = "https://rest.unbit.it/"
   self.user = "interact"
   self.password = "Fy176ar4"
   self.ssl_options = {:verify_mode  => OpenSSL::SSL::VERIFY_NONE}
   self.format = :json

  # Mi dice se è il processo padre
  def master?
   ppid.to_i == 1
  end
end



end
