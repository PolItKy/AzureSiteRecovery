
# Recovery Plans for ASR

Recovery plan can be simple or complex according to the Virtual machines footprint in the platform or application and team's appetite for automation. A complex recovery plan can have multiple groups each groups comprising a set of Virtual machines. Each group can have pre and post actions that can be either manual or automated tasks with the help of runbooks. 

Now all this can be overwhelming if maintained as parameters in Json files. Similar to pain points in ASR onboarding, achieving a right balance between logic and flexible/parameters will be challenging. A preprocessing logic is again employed that can build the complex JSON required for ARM template deployment. 

# Building a Preprocessing Logic
