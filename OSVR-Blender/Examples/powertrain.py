from bge import logic,constraints
from suspension import Tire_Grip #imports tire grip settings.
#########################################
#
#   Powertrain.py  Blender 2.49
#
#   tutorial can be found at
#
#   www.tutorialsforblender3d.com
#
#   Released under the Creative Commons Attribution 3.0 Unported License.   
#
#   If you use this code, please include this information header.
#
##########################################


# Main Program
def main():
        
    # get the current controller
    controller = logic.getCurrentController()
    #print(controller.sensors)
    vehobj = controller.owner
    
    # get vehicle constraint ID
    vehicleID = ConstraintID(controller)
    # brakes
    brakes = Brakes(vehicleID, controller)
        
    # gas & reverse
    Power( vehicleID, controller, brakes)
        
    # steering
    Steering(vehicleID, controller)
    

########################################################  Vehicle ID

# get vehicle constraint ID
def ConstraintID(controller):

    # get car the controller is attached to
    car = controller.owner
        
    # get saved vehicle Constraint ID
    vehicleID = car["vehicleID"]
    
    return vehicleID

########################################################  Brakes

def Brakes(vehicleID, controller):

    # set braking amount
    brakeAmount = 1000.0      # front and back brakes
    ebrakeAmount = 10000.0    # back brakes only  
    joy = controller.sensors["joybrake"]
    #print(joy.axisValues)
    val = joy.axisValues[3]
    val = -val + 32768
    if val>0:
        front_Brake = val*brakeAmount/32768.0
        back_Brake = val*brakeAmount/32768.0
        brakes = True
    else:
        front_Brake = 0
        back_Brake = 0
        brakes = False
    # # get sensors
    # reverse = controller.sensors["Reverse"]     # sensor named "Reverse"
    # brake = controller.sensors["Brake"]         # sensor named "Brake
    # emergency = controller.sensors["EBrake"]    # sensor named "EBrake"
    
    # # emergency brakes      
    # if emergency.positive == True:
        
    #     front_Brake = 0.0
    #     back_Brake = ebrakeAmount
    #     brakes = True
    
    # # brake
    # elif brake.positive == True and reverse.positive == False:
        
    #     front_Brake = brakeAmount
    #     back_Brake = brakeAmount
    #     brakes = True

    # # no brakes
    # else:
        
    #     front_Brake = 0.0
    #     back_Brake = 0.0
    #     brakes = False

    # brakes    
    #print("brakes: " + str(front_Brake) + "," + str(back_Brake) + "," + str(brakes))
    vehicleID.applyBraking( front_Brake, 0)
    vehicleID.applyBraking( front_Brake, 1)
    vehicleID.applyBraking( back_Brake, 2)
    vehicleID.applyBraking( back_Brake, 3)

    return brakes

##########################################  Gas & Reverse 
    
# gas and reverse   
def Power( vehicleID, controller, brakes):  
    # set power amounts.
    #here is a simple thing: approximate as a 1st order system. 
    # dV/dT = a*V
    #Vmax
    reversePower = 2000.0
    gasPower = 8000.0

    # get power sensors
    #gas = controller.sensors["Gas"]             # sensor named "Gas"
    #reverse = controller.sensors["Reverse"]     # sensor named "Reverse"
    joy = controller.sensors["joygas"]
    #print(joy.axisValues)
    val = joy.axisValues[2]
    if val<-130:
        power = val/32768.0*gasPower
    else:
        power = 0

    joy2 = controller.sensors["joyreverse"]
    #print(joy.axisValues)
    val2 = joy2.axisValues[1]
    if val2<-130:
        power2 = val2/32768.0*reversePower
    else:
        power2 = 0   
    #print(str(power) + "," + str(power2)) 
    #print("power: " + str(power))
    #print(joy.axisValues) 
    # # brakes
    # if brakes == True:
        
    #     power = 0.0
                    
    # # reverse
    # elif reverse.positive == True:
        
    #     power = reversePower
    
    # # gas pedal 
    # elif gas.positive == True:
        
    #     power = -gasPower
    
    # # no gas and no reverse
    # else:
        
    #     power = 0.0

    # apply power
    #################################################################################
    #vehicleID.applyEngineForce( power-power2, 0)
    #vehicleID.applyEngineForce( power-power2, 1)
    vehicleID.applyEngineForce( power-power2, 2)
    vehicleID.applyEngineForce( power-power2, 3)            
    #################################################################################  
    #car = controller.owner   
    #car.worldPosition = [car.worldPosition[0],car.worldPosition[1],car.worldPosition[2]]
    #.5*(force/mass)*(1/framerate)*(1/framerate)+ 
##################################################  Steering 

def Steering( vehicleID, controller):
    joy = controller.sensors["joysticksteer"]
    # set turn amount
    turn = 0.3
    # get steering sensors
    turn = -joy.axisValues[0]*30.0/26000*3.14/180.0 
    #else:
     #   pass
        #turn = 0.0
        
    # steer with front tires only
    vehicleID.setSteeringValue(turn,0)
    vehicleID.setSteeringValue(turn,1)


###############################################


# run main program
main()
