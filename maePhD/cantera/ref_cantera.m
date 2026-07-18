% cantera matlab tutorial notes
% https://cantera.org/tutorials/matlab-tutorial.html

% activate the cantera python environment before launching matlab
% $ conda activate cantera24

gas1 = GRI30
%creates object gas1 that implements GRI-Mech 3.0 (53-species / 325-reaction natural gas model)

gas1
%dispaly properties of gas1 object

setTemperature(gas1,1200)
%*Setting the temperature is done holding density and composition fixed. (The pressure changes.)
%*Setting the pressure is done holding temperature and composition fixed. (The density changes.)
%*Setting the composition is done holding temperature and density fixed. (The pressure changes).

set(gas1,'T',900.0,'P',1.e5,'X','CH4:1,O2:2,N2:7.52')
%set property values for Temperature, Pressure, Mole Fractions

gas1 = Solution('ffcmy9reduced30.cti','gas')
% load object from cti file

class(gas1)
% displayes matlab class that gas1 belongs to

methods Solution -full
% long list of all the methods for a Solutions object
%Solution
%advanceCoverages  % Inherited from Kinetics
%atomicMasses  % Inherited from ThermoPhase
%binDiffCoeffs  % Inherited from Transport
%chemPotentials  % Inherited from ThermoPhase
%clear
%cp_R  % Inherited from ThermoPhase
%cp_mass  % Inherited from ThermoPhase
%cp_mole  % Inherited from ThermoPhase
%creationRates  % Inherited from Kinetics
%critDensity  % Inherited from ThermoPhase
%critPressure  % Inherited from ThermoPhase
%critTemperature  % Inherited from ThermoPhase
%...


