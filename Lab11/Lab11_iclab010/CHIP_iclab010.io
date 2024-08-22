######################################################
#                                                    #
#  Silicon Perspective, A Cadence Company            #
#  FirstEncounter IO Assignment                      #
#                                                    #
######################################################

Version: 2

#Example:  
#Pad: I_CLK 		W

#define your iopad location her

#
Pad: VDDP0           N
Pad: VDDC0           N
Pad: VDDP1           N
Pad: VDDC1           N
      
Pad: I_CLK           N
Pad: I_RESET         N
Pad: I_I_MAT_IDX     N
      
Pad: GNDC1           N
Pad: GNDP1           N
Pad: GNDC0           N
Pad: GNDP0           N
      
#      
Pad: VDDP2           E
Pad: VDDC2           E
Pad: VDDP3           E
Pad: VDDC3           E

pad: I_VALID         E
pad: I_VALID2        E
pad: I_MATRIX        E

Pad: GNDC3           E
Pad: GNDP3           E
Pad: GNDC2           E
Pad: GNDP2           E

#
Pad: VDDP4           S
Pad: VDDC4           S
Pad: VDDP5           S
Pad: VDDC5           S

Pad: O_VALID         S
Pad: O_OUT_VALUE     S
Pad: I_W_MAT_IDX     S

Pad: GNDC5           S
Pad: GNDP5           S
Pad: GNDC4           S
Pad: GNDP4           S

#
Pad: VDDP6           W
Pad: VDDC6           W
Pad: VDDP7           W
Pad: VDDC7           W

pad: I_MATRIX_SIZE0  W
pad: I_MATRIX_SIZE1  W
      
Pad: GNDC7           W
Pad: GNDP7           W
Pad: GNDC6           W
Pad: GNDP6           W

#
Pad: PCLR SE PCORNER
Pad: PCUL NW PCORNER
Pad: PCUR NE PCORNER
Pad: PCLL SW PCORNER