%Coeffs for wall segments in VALOUR
%
% This file should be loaded in each floor plan!
%
% Paul Meissner, SPSC Lab, Graz University of Technology
% Date: Jan 25, 2011


%weight definition  (everyting > 0 blocks signals, everything <= 0 does not)
fp_coeffs.trans = -1;           %reflection and transmission (i.e. causes a VA but does not block)
fp_coeffs.unspec_VA = 1;           %unspecified, reflective (use for VAs)
fp_coeffs.door_var =  2;         %used for specifying a door (if this should be used sometime)
fp_coeffs.concrete_wall = 3;     
fp_coeffs.glass = 4;             %used for every glass surface, should be more specific later
fp_coeffs.metal = 5;
fp_coeffs.dummy = 0;             %these just used internally, never define something reflecting
fp_coeffs.absorb = 17;      %this segment type blocks signals, but does not cause a VA

%Segment connection types
seg_con.unspec = -1;
seg_con.corner = 1;    %thats a wall corner (double reflection possible)
seg_con.edge = 2;      %a wall edge (no reflection, just a scatterer)
seg_con.cont = 3;      %a continuation (zero degree), just a material change





