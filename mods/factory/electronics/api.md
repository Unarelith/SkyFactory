##device definition

a node that is an electronic device has to follow the following node definitions:
* groups has to contain "factory_electronic" with a value greater than zero
* on_push_electricity(pos,energy,side_from)
  * doesn't have to be present
  * is called when energy is distributed to this device
  * has to be a function returning the remaining energy that can be pushed to other devices

##device util

factory.electronics.device.set_infotext(meta)
* set the infotext for a device
* show name, status (optional) and charge

factory.electronics.device.get_energy(meta)
* get the energy stored in a device
* get the meta field "factory_energy"

factory.electronics.device.set_energy(meta,value)
* set the energy stored in a device

factory.electronics.device.set_name(meta,device_name)
* set the name (description) of a device
* is shown in the infotext

factory.electronics.device.set_status(meta,status)
* set the status of a device
* can be ""
* is shown in the infotexts

factory.electronics.device.set_max_charge(meta,max_charge)
* set the maximum of energy that can be stored in a device
* set the meta field "factory_max_charge"

factory.electronics.device.get_max_charge(meta)
* get the maximum charge

factory.electronics.device.store(meta, push_energy, max_energy)
* store the push_energy with a maximum of max_energy and return the remaining push_energy

factory.electronics.device.try_use(meta,energy_amount)
* if enough energy is stored draw energy_amount from it and return true
* if not enough energy is stored return false

factory.electronics.is_device(node)
* check if a node is an electronic device
* check for the item group "factory_electronic"
* node can be a node name or a node or a position

factory.electronics.device.distribute(pos,energy_amount)
* distribute the energy_amount to all connected devices and return the energy remaining
