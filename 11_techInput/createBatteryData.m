%% createBatteryData
% Function to return battery model struct during parameter-setting phase of
% main simulation. Struct will be used to instantiate storage object and
% the model parameters are determined.
%
% Input == (parameters)
% batteryType           [-]     string with parameter set to be chosen (switch case below)
% batteryNominalVoltage [V]     Target nominal voltage of battery pack. 
% batteryNominalEnergy  [Ws]    Target nominal energy of battery pack. 
%
% Output ==
% etaBatt               [pu]    Energy efficiency of battery (single val or array)
% selfDischargeRate     [pu/s]  self discharge rate of battery cell  
% batteryNominalVoltage [V]     Actual nominal voltage of battery pack based on # of cells in series.
% batteryNominalEnergy  [Ws]    Actual nominal energy of battery pack based on # of cells in pack.
% SOCLimLow             [pu]    Lower limit of allowed SOC range
% SOCLimHigh            [pu]    Upper limit of allowed SOC range
% batteryModelParameter [-]     Struct with battery model parameters for EC model
% setPowerStorageMethod [-]     fhandle with setPowerStorageMethod
%
% Returns battery data (eta, self discharge rate...) of chosen technology 
% for calculation in model. Nominal voltage and energy are rounded from
% target values and calculated according to serial and parallel connection
% of cells.
% Call of function during parameter-setup phase of main simulation.
%
% Available batteryType to choose:
%   # LiB_Generic_Powerflow
%   # Lib_Rosenkranz
%   # LiB_baseLineScenario
%   # LiB_strongAging
%   # CLFP_Goebel
%   # Dummy
%   # AgingTest
%   # LiB_NMC_Tesla_100DOD
%   # LiB_NMC_Tesla_80DOD 
%   # NMC_Tesla_DailyCyclePowerwall
%   # CLFP_Sony_US26650_Experiment
%   # CLFP_Sony_US26650_Experiment_OCV_R
%   # VRF_Battery (ZAE)
%   # C/NMC IHR18650A Molicel
%
% 2016-06-16   Maik Naumann / Nam Truong
% 2018-12-13   Update: Daniel Kucevic
%
%%
function [  etaBatt,            ...
            rSelfDischarge,     ...
            voltBattNom,        ...
            eBattNom,           ...
            socLimLow,          ...
            socLimHigh,         ...
            battMdlParams,      ...
            setPStorageMethod] = createBatteryData( varargin )

%% input parsing
p       = inputParser;    % generate parsing handle
defVal  = NaN;       % set def value for parsing
% add parameter accepted for input
addParameter(p, 'typeBatt',     defVal);
addParameter(p, 'voltBattNom',  defVal);
addParameter(p, 'eBattNom',     defVal);
addParameter(p, 'socLimLow',    defVal); 
addParameter(p, 'socLimHigh',   defVal); 
% parse input
parse(p, varargin{:})
% write parsed input into local var
typeBatt    = p.Results.typeBatt;
voltBattNom = p.Results.voltBattNom;
eBattNom    = p.Results.eBattNom;
socLimLow   = p.Results.socLimLow; 
socLimHigh  = p.Results.socLimHigh;
%% Initialize battery model parameters for power flow models
battMdlParams = [];
% SOCLimLow = 0;
% SOCLimHigh = 1;

%% switch case for battery type selection
switch lower(typeBatt)
    %% 'LiB_Rosenkranz', 'CLFP_Goebel' 
    % Generic power flow model
    case {'lib_rosenkranz','clfp_goebel'}
        % Generic values as given by different sources
        etaBatt             = 0.95;                                     % [pu]      battery efficiency  
        rSelfDischarge      = mean([0.02,0.01]) /(30.5*24*3600);        % [pu/s]    self discharge rate 
        setPStorageMethod   = @setPowerStoragePowerFlow;                % [-]       fhandle for power flow calculation
   
        
    %% 'NMC_Tesla_DailyCyclePowerwall' 
    % Generic power flow model
    case {'nmc_tesla_dailycyclepowerwall'}
        % Estimated values of Tesla Daily Cycle Powerwall
        etaBatt             = sqrt(0.92);                               % [pu]      battery efficiency
        rSelfDischarge      = mean([0.02,0.01]) /(30.5*24*3600);        % [pu/s]    self discharge rate 
        setPStorageMethod   = @setPowerStoragePowerFlow;                % [-]       fhandle for power flow calculation    
           
        
    %% CLFP_Sony_US26650_Experiment
    % Powerflow model based on experimental data of cell
    case('clfp_sony_us26650_experiment') 
        load('CLFP_Sony_US26650_Experiment_Efficiency.mat')         % Load cell parameters
        etaBatt             = efficiency;                           % [pu, pu]  powerRatio (discharge, charge), battery efficiency
        rSelfDischarge      = mean([0.02,0.01]) /(30.5*24*3600);    % [pu/s]    self discharge rate per second related to nominal capacity
        setPStorageMethod   = @setPowerStoragePowerFlow;            % [-]       fhandle for power flow calculation    
 
        
    %% CLFP_Sony_US26650_Experiment_OCV_R
    % EC model based on experimental data of cell. System values are
    % scaled.
    case('clfp_sony_us26650_experiment_ocv_r')
        load('CLFP_Sony_US26650_Experiment_OCV_R.mat')          % Load cell parameters
        etaBatt         = 0.95;                                 % [pu]      battery efficiency  %TODO Does this make sense?
        %rSelfDischarge  = mean([0.02,0.01]) /(30.5*24*3600);    % [pu/s]    self discharge rate per second related to nominal capacity
        rSelfDischarge  = 0;
		% temp vars for calculations
        eNom        = Cell.U_Nom * Cell.Q_Nom;                  % [Ws] nominal energy of cell
        nSerial     = ceil(voltBattNom / Cell.U_Nom);           % [-] no of serial cells
        nParallel   = ceil(eBattNom / (eNom * nSerial) );       % [-] no of parallel cells
        nCells      = nSerial * nParallel;                      % [-] total no of cells
        disp('Battery specified capacity (in kWh)')
        eBattNom/3600000
        eBattNom    = nParallel * nSerial * eNom;               % [WS] battery nominal energy
        disp('Battery corrected capacity (in kWh)')
        eBattNom/3600000
%         uNom        = Cell.U_Nom * nSerial;
        % OCV
        ocvAccuracy = size( Cell.SOC_Uocv, 1 );         % no. of data points of OCV
        ocv         = Cell.SOC_Uocv(:,2) * nSerial;     % OCV curve
        if ( ocv(1) - ocv(end) ) > 0
            ocv = flip(ocv);
        end
        % Coulombic capacity and efficiency
        qNom        = Cell.Q_Nom * nParallel;       % Ah capacity
        etaCoul     = System.eta_Coulomb;           % coulomb efficiency
        % inner resistance ri
        riAccuracy  = 100;                          % no. of data points for ri in each dimension
        % discharge case
        riDischTMin = min( Cell.Ri_Disch_Tvalues ); % min temperature
        riDischTMax = max( Cell.Ri_Disch_Tvalues ); % max temperature
        riDisch     = griddata( Cell.Ri_Disch_Tvalues, ...
                                Cell.Ri_Disch_SOCvalues, Cell.Ri_Disch, ...
                                linspace( riDischTMin, riDischTMax, riAccuracy ), ...
                                linspace( 0, 1, riAccuracy).' ); % ri matrix
        riDisch     = riDisch * nSerial / nParallel;
        % charge case
        riChTMin    = min( Cell.Ri_Ch_Tvalues );    % min temperature
        riChTMax    = max( Cell.Ri_Ch_Tvalues );    % max temperature
        riCh        = griddata( Cell.Ri_Ch_Tvalues, ... 
                                Cell.Ri_Ch_SOCvalues, Cell.Ri_Ch, ...
                                linspace( riChTMin, riChTMax, riAccuracy), ...
                                linspace( 0, 1, riAccuracy).' ); % ri matrix
        riCh        = riCh * nSerial / nParallel;
        % operational limits
        uMin        = Cell.U_Min * nSerial;       % min cell voltage
        uMax        = Cell.U_Max * nSerial;       % max cell voltage
        socMin      = Cell.SOC_Min;     % min cell SOC
        socMax      = Cell.SOC_Max;     % max cell SOC
        iMinExt     = Cell.I_Min_Ext * nParallel;   % min current
        iMaxExt     = Cell.I_Max_Ext * nParallel;   % max current        
        % write parameters into common struct
        battMdlParams.nCells        = nCells;
        battMdlParams.ocvAccuracy   = ocvAccuracy;
        battMdlParams.ocv           = ocv;
        battMdlParams.riAccuracy    = riAccuracy;
        battMdlParams.riDischTMin   = riDischTMin;
        battMdlParams.riDischTMax   = riDischTMax;
        battMdlParams.riDisch       = riDisch;
        battMdlParams.riChTMin      = riChTMin;
        battMdlParams.riChTMax      = riChTMax;
        battMdlParams.riCh          = riCh;
        battMdlParams.uMin          = uMin;
        battMdlParams.uMax          = uMax;
        battMdlParams.socMin        = socMin;
        battMdlParams.socMax        = socMax;
        battMdlParams.qNom          = qNom;
        battMdlParams.etaCoul       = etaCoul;
        battMdlParams.iMinExt       = iMinExt;
        battMdlParams.iMaxExt       = iMaxExt;
        % Parameters of thermal model
        battMdlParams.thermA        = Cell.A;
        battMdlParams.thermAlpha    = Cell.alpha;
        battMdlParams.thermM        = Cell.m;
        battMdlParams.thermCp       = Cell.cp;
        % Method for calculation with EC model
        setPStorageMethod           = @setPowerStorageEquivalentCircuit;        
    
    %% 'VRF_Battery (ZAE)*' 
    % Generic power flow model
    case {'vrf_battery'}
        % Estimated values of Tesla Daily Cycle Powerwall
        load('VRF_Battery_Efficiency.mat');
        etaBatt             = VRF_Battery_Efficiency;                   % [pu]      battery efficiency
        rSelfDischarge      = 0.015/(30.5*24*3600);                     % [pu/s]    self discharge rate 
        setPStorageMethod   = @setPowerStoragePowerFlow;                % [-]       fhandle for power flow calculation    
  %% C/NMC IHR18650A Molicel
  % based on MA Ni developed at EES/TUM
    case('cnmc_molicel_ihr_18650a')
        load('CNMC_Molicel_IHR_18650A_dat.mat');        
        etaBatt         = 0.95;                                 % [pu]      battery efficiency  
        rSelfDischarge  = 0;    % [pu/s]    self discharge rate per second related to nominal capacity
        % temp vars for calculations
        eNom        = Cell.U_Nom * Cell.Q_Nom;                  % [Ws] nominal energy of cell
        nSerial     = ceil(voltBattNom / Cell.U_Nom);           % [-] no of serial cells
        nParallel   = ceil(eBattNom / (eNom * nSerial) );       % [-] no of parallel cells
        nCells      = nSerial * nParallel;                      % [-] total no of cells
%         uNom        = Cell.U_Nom * nSerial;
        % OCV
        disp('Battery specified capacity (in kWh)')
        eBattNom/3600000
        eBattNom    = nParallel * nSerial * eNom;               % [WS] battery nominal energy
        disp('Battery corrected capacity (in kWh)')
        eBattNom/3600000
        
        ocvAccuracy = size( Cell.SOC_Uocv, 1 );         % no. of data points of OCV
        ocv         = Cell.SOC_Uocv(:,2) * nSerial;     % OCV curve
        if ( ocv(1) - ocv(end) ) > 0
            ocv = flip(ocv);
        end
        % Coulombic capacity and efficiency
        qNom        = Cell.Q_Nom * nParallel;       % Ah capacity
        etaCoul     = System.eta_Coulomb;           % coulomb efficiency
        % inner resistance ri
        riAccuracy  = 100;                          % no. of data points for ri in each dimension
        % discharge case
        riDischTMin = min( Cell.Ri_Disch_Tvalues ); % min temperature
        riDischTMax = max( Cell.Ri_Disch_Tvalues ); % max temperature
        riDisch     = griddata( Cell.Ri_Disch_Tvalues, ...
                                Cell.Ri_Disch_SOCvalues, Cell.Ri_Disch, ...
                                linspace( riDischTMin, riDischTMax, riAccuracy ), ...
                                linspace( 0, 1, riAccuracy).' ); % ri matrix
        riDisch     = riDisch * nSerial / nParallel;
        % charge case
        riChTMin    = min( Cell.Ri_Ch_Tvalues );    % min temperature
        riChTMax    = max( Cell.Ri_Ch_Tvalues );    % max temperature
        riCh        = griddata( Cell.Ri_Ch_Tvalues, ... 
                                Cell.Ri_Ch_SOCvalues, Cell.Ri_Ch, ...
                                linspace( riChTMin, riChTMax, riAccuracy), ...
                                linspace( 0, 1, riAccuracy).' ); % ri matrix
        riCh        = riCh * nSerial / nParallel;
        % operational limits
        uMin        = Cell.U_Min * nSerial;       % min cell voltage
        uMax        = Cell.U_Max * nSerial;       % max cell voltage
        socMin      = Cell.SOC_Min;     % min cell SOC
        socMax      = Cell.SOC_Max;     % max cell SOC
        iMinExt     = Cell.I_Min_Ext * nParallel;   % min current
        iMaxExt     = Cell.I_Max_Ext * nParallel;   % max current        
        % write parameters into common struct
        battMdlParams.nCells        = nCells;
        battMdlParams.ocvAccuracy   = ocvAccuracy;
        battMdlParams.ocv           = ocv;
        battMdlParams.riAccuracy    = riAccuracy;
        battMdlParams.riDischTMin   = riDischTMin;
        battMdlParams.riDischTMax   = riDischTMax;
        battMdlParams.riDisch       = riDisch;
        battMdlParams.riChTMin      = riChTMin;
        battMdlParams.riChTMax      = riChTMax;
        battMdlParams.riCh          = riCh;
        battMdlParams.uMin          = uMin;
        battMdlParams.uMax          = uMax;
        battMdlParams.socMin        = socMin;
        battMdlParams.socMax        = socMax;
        battMdlParams.qNom          = qNom;
        battMdlParams.etaCoul       = etaCoul;
        battMdlParams.iMinExt       = iMinExt;
        battMdlParams.iMaxExt       = iMaxExt;
        % Parameters of thermal model
        battMdlParams.thermA        = Cell.A;
        battMdlParams.thermAlpha    = Cell.alpha;
        battMdlParams.thermM        = Cell.m;
        battMdlParams.thermCp       = Cell.cp;
        % Method for calculation with EC model
        setPStorageMethod           = @setPowerStorageEquivalentCircuit;    
        
    otherwise % catch mistake of not specifying model parameters
        error([mfilename('fullpath') ': No battery technology specified. Please chose battery to determine model parameters.'])
end

% show chosen method in command window.
disp([mfilename ': <strong>', typeBatt, '</strong>'])

end

