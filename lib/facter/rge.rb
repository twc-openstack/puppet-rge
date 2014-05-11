Facter.add("rge_reboot_allowed") do 
  setcode do
    if File.exists?('/etc/RGE_DISARMED') 
      true
    else
      false
    end
  end
end
