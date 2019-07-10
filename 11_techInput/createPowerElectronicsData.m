%% createPowerElectronicsData
% Returns power electronics Data according to chosen model of efficiency.
%
% Input == (parameters)
% inverterMethod    [-]     string for switch case to choose method to generate efficiency curve
% inverterP_0       [-]     parameter for curve equation
% inverterK         [-]     parameter for curve equation
% powerEletronicsEta        [pu]    parameter for constant method
%
% Output ==
% inverterEta       [pu]    efficiency curve / value
%
% Efficiency curve of power electronics / inverter is generated in function
% according to chosen method 'Formula', 'Array', or 'constant'. Either
% literature equation is used to generate curve or array in function.
% Alternatively constant efficiency value is used for constant method.
%
% 2015-10-12  Maik Naumann

%----------------ADDED: NEW POWER ELECTRONICS METHOD: LOOK UP TABLE ('LUT')------------------------
% 2018-08-01 Anupam Parlikar
%
%----------------ADDED: Modular inverter concept for methods formular and 'notton'-----------------
% 2018-08-13 Daniel Kucevic / Manuel Pietsch
%   Update: 2019-07-08 Daniel Kucevic
%

function [inverterEta, inverterEta_Ch, inverterEta_Dis] = createPowerElectronicsData( varargin )
%% input parsing
p       = inputParser;  % generate parsing handle
defVal  = NaN;          % set def value for parsing
defUdc  = 'nom';
% add parameter accepted for input
addParameter(p, 'inverterMethod',       defVal);
addParameter(p, 'inverterP_0',          defVal);
addParameter(p, 'inverterK',            defVal);
addParameter(p, 'inverterEta',          defVal);
addParameter(p, 'inverterNumber',       defVal);
addParameter(p, 'inverterSwitch',       defVal);
addParameter(p, 'voltBattNom',          defVal);
addParameter(p, 'etaAccuracy',          defVal);
addParameter(p, 'uDC',                  defUdc);
% parse input
parse(p, varargin{:})
% write parsed input into local var
inverterMethod          = p.Results.inverterMethod;
p0                      = p.Results.inverterP_0;
inverterK               = p.Results.inverterK;
inverterEta             = p.Results.inverterEta;
inverterNumber          = round(p.Results.inverterNumber);
inverterSwitch          = p.Results.inverterSwitch;
uDC                     = p.Results.uDC;
batteryNominalVoltage   = p.Results.voltBattNom;
etaAccuracy             = p.Results.etaAccuracy;


pIn             = 0:0.001:1;
inverterEta_Ch  = [];
inverterEta_Dis = [];

%% Error handling for modular Power Electronics input
% min 1 Inverter, max 10 Standard case = 2 inverter
if (inverterNumber > 10 || inverterNumber < 1)
    inverterNumber = 2;
    warning([mfilename('fullpath') ': Number of inverters must be in the range of 1 to 10. Automatic set to 2 inverters']);
end
% min
if (inverterSwitch > 1 || inverterSwitch < 0.5)
    inverterSwitch = 0.8;
    warning([mfilename('fullpath') ': Switching point of inverters must be in the range of 50% to 100%. Automatic set to 80%']);
end

%% Switch case to determine method for generating efficiency curve
switch lower( inverterMethod )
    
    %% Formula
    % Inverter efficiency according to given function.
    %
    %   Notton, G.; Lazarov, V.; Stoyanov, L. (2010): Optimal sizing of 
    %       a grid-connected PV system for various PV module technologies 
    %       and inclinations, inverter efficiency characteristics and 
    %       locations. In: Renewable Energy 35 (2), S. 541–554. 
    %       DOI: 10.1016/j.renene.2009.07.013.
    % type1: p0 = 0.0145, k = 0.0437
    % type2: p0 = 0.0072, k = 0.0345
    % type3: p0 = 0.0088, k = 0.1149
    case('formula')
        inverterEta     = pIn./ (pIn + p0 + inverterK * pIn.^2);
        
        if inverterNumber > 1
            inverterTemp = inverterEta;
            warning('off','MATLAB:colon:nonIntegerIndex')
            
            for i = 1:(inverterNumber - 1)             
                startIndex_Modular          = (i-1)* floor(length(inverterEta)/inverterNumber*inverterSwitch) + 1;
                endIndex_Modular            = i * floor(length(inverterEta)/inverterNumber*inverterSwitch);
                startIndex_Single           = floor(1 + length(inverterEta)*inverterSwitch - length(inverterEta)*inverterSwitch / i);
                endIndexCurve_Single        = floor(length(inverterEta)*inverterSwitch);
                
                step = (endIndexCurve_Single - (startIndex_Single - 1)) / (endIndex_Modular - (startIndex_Modular - 1));
                
                inverterEta(startIndex_Modular:endIndex_Modular) = inverterTemp(startIndex_Single:step:endIndexCurve_Single);                               
            end
            warning('on','MATLAB:colon:nonIntegerIndex')
        end
        
    case 'notton type1'
        p0              = 0.0145;
        k               = 0.0437;
        inverterEta     = pIn./ (pIn + p0 + k * pIn.^2);
        
        if inverterNumber > 1
            inverterTemp = inverterEta;
            warning('off','MATLAB:colon:nonIntegerIndex')
            
            for i = 1:(inverterNumber - 1)             
                startIndex_Modular          = (i-1)* floor(length(inverterEta)/inverterNumber*inverterSwitch) + 1;
                endIndex_Modular            = i * floor(length(inverterEta)/inverterNumber*inverterSwitch);
                startIndex_Single           = floor(1 + length(inverterEta)*inverterSwitch - length(inverterEta)*inverterSwitch / i);
                endIndexCurve_Single        = floor(length(inverterEta)*inverterSwitch);
                
                step = (endIndexCurve_Single - (startIndex_Single - 1)) / (endIndex_Modular - (startIndex_Modular - 1));
                
                inverterEta(startIndex_Modular:endIndex_Modular) = inverterTemp(startIndex_Single:step:endIndexCurve_Single);                               
            end
            warning('on','MATLAB:colon:nonIntegerIndex')
        end
        
    case 'notton type2'
        p0              = 0.0072;
        k               = 0.0345;
        inverterEta     = pIn./ (pIn + p0 + k * pIn.^2);
        
        if inverterNumber > 1
            inverterTemp = inverterEta;
            warning('off','MATLAB:colon:nonIntegerIndex')
            
            for i = 1:(inverterNumber - 1)             
                startIndex_Modular          = (i-1)* floor(length(inverterEta)/inverterNumber*inverterSwitch) + 1;
                endIndex_Modular            = i * floor(length(inverterEta)/inverterNumber*inverterSwitch);
                startIndex_Single           = floor(1 + length(inverterEta)*inverterSwitch - length(inverterEta)*inverterSwitch / i);
                endIndexCurve_Single        = floor(length(inverterEta)*inverterSwitch);
                
                step = (endIndexCurve_Single - (startIndex_Single - 1)) / (endIndex_Modular - (startIndex_Modular - 1));
                
                inverterEta(startIndex_Modular:endIndex_Modular) = inverterTemp(startIndex_Single:step:endIndexCurve_Single);                               
            end
            warning('on','MATLAB:colon:nonIntegerIndex')
        end        
        
    case 'notton type3'
        p0              = 0.0088;
        k               = 0.1149;
        inverterEta     = pIn./ (pIn + p0 + k * pIn.^2);
        
        if inverterNumber > 1
            inverterTemp = inverterEta;
            warning('off','MATLAB:colon:nonIntegerIndex')
            
            for i = 1:(inverterNumber - 1)             
                startIndex_Modular          = (i-1)* floor(length(inverterEta)/inverterNumber*inverterSwitch) + 1;
                endIndex_Modular            = i * floor(length(inverterEta)/inverterNumber*inverterSwitch);
                startIndex_Single           = floor(1 + length(inverterEta)*inverterSwitch - length(inverterEta)*inverterSwitch / i);
                endIndexCurve_Single        = floor(length(inverterEta)*inverterSwitch);
                
                step = (endIndexCurve_Single - (startIndex_Single - 1)) / (endIndex_Modular - (startIndex_Modular - 1));
                
                inverterEta(startIndex_Modular:endIndex_Modular) = inverterTemp(startIndex_Single:step:endIndexCurve_Single);                               
            end
            warning('on','MATLAB:colon:nonIntegerIndex')
        end        
    
    % data sheets: 
    % https://www3.fronius.com/cps/rde/xbcr/SID-F7812949-5B8F237D/fronius_international/SE_DS_Fronius_Symo_Hybrid_EN_386411_snapshot.pdf
    case 'fronius symo hybrid 3'
        pNorm           = [0.05, 0.1, 0.2, 0.25, 0.3, 0.5, 0.75, 1];
        uMPPmin         = 190;
        uMPPmax         = 800;
        pPVinMax        = 5e3;
        uInMin          = 150;
        uDCstart        = 200;
        uDCnom          = 595;
        uInMax          = 1000;
        etaUdcMPPmin    = [0.785, 0.831, 0.900, 0.912, 0.924, 0.945, 0.951, 0.954];
        etaUdcNom       = [0.773, 0.838, 0.930, 0.939, 0.947, 0.967, 0.973, 0.977];
        etaUdcMPPmax    = [0.669, 0.766, 0.906, 0.919, 0.933, 0.960, 0.966, 0.970];
        
        switch uDC
            case 'nom'
                etaInv0 = etaUdcNom;
            case 'mppmin'
                etaInv0 = etaUdcMPPmin;
            case 'mppmax'
                etaInv0 = etaUdcMPPmax;
        end
        inverterEta     = interp1(pNorm, etaInv0, pIn, 'linear','extrap');
        
    case 'fronius symo hybrid 4'
        pNorm           = [0.05, 0.1, 0.2, 0.25, 0.3, 0.5, 0.75, 1];
        uMPPmin         = 250;
        uMPPmax         = 800;
        pPVinMax        = 5e3;
        uInMin          = 150;
        uDCstart        = 200;
        uDCnom          = 595;
        uInMax          = 1000;
        etaUdcMPPmin    = [0.801, 0.862, 0.916, 0.932, 0.939, 0.949, 0.954, 0.956];
        etaUdcNom       = [0.795, 0.881, 0.942, 0.953, 0.962, 0.971, 0.977, 0.979];
        etaUdcMPPmax    = [0.701, 0.832, 0.924, 0.942, 0.951, 0.964, 0.970, 0.973];
        
        switch uDC
            case 'nom'
                etaInv0 = etaUdcNom;
            case 'mppmin'
                etaInv0 = etaUdcMPPmin;
            case 'mppmax'
                etaInv0 = etaUdcMPPmax;
        end
        inverterEta     = interp1(pNorm, etaInv0, pIn, 'linear','extrap');
        
    case 'fronius symo hybrid 5'
        pNorm           = [0.05, 0.1, 0.2, 0.25, 0.3, 0.5, 0.75, 1];
        uMPPmin         = 315;
        uMPPmax         = 800;
        pPVinMax        = 5e3;
        uInMin          = 150;
        uDCstart        = 200;
        uDCnom          = 595;
        uInMax          = 1000;
        etaUdcMPPmin    = [0.816, 0.892, 0.932, 0.940, 0.945, 0.953, 0.956, 0.958];
        etaUdcNom       = [0.816, 0.925, 0.953, 0.965, 0.967, 0.975, 0.979, 0.979];
        etaUdcMPPmax    = [0.734, 0.897, 0.942, 0.953, 0.960, 0.968, 0.973, 0.975];
        
        switch uDC
            case 'nom'
                etaInv0 = etaUdcNom;
            case 'mppmin'
                etaInv0 = etaUdcMPPmin;
            case 'mppmax'
                etaInv0 = etaUdcMPPmax;
        end
        inverterEta     = interp1(pNorm, etaInv0, pIn, 'linear','extrap');
        
    % read from plot Singer et al. - Modular Multilevel Parallel Converter
    % based Split Battery System (M2B) for Stationary Storage Applications
    case 'multilevel singer'
        pNorm           = [0.10, 0.25, 0.50, 0.75, 1.000, 1.250, 1.50, 1.75, 2.00, 2.500, 2.625, 3.00]/3;
        etaInv0         = [0.87, 0.96, 0.97, 0.98, 0.982, 0.986, 0.99, 0.99, 0.99, 0.985, 0.983, 0.98];
        inverterEta     = interp1(pNorm, etaInv0, pIn, 'linear','extrap');
        
   
    %% Look up Table based on Michael Schimpe
    % Based on Siemens Sinamics S120 inverter modeled by Michael Schimpe (EES)
    % https://w3.siemens.com/mcms/mc-solutions/de/umrichter/niederspannungsumrichter/sinamics-s/servoantrieb/seiten/sinamics-s120.aspx
    % This method uses a power electronics model based on real world measured performance of the aforementioned inverter
    case 'lut'
        if (batteryNominalVoltage <= 750 && batteryNominalVoltage >= 600)
            Create_PE_Parameter_HILFit; % Calls the top level script of the Power Electronics program
            inverterEta     = [];
            inverterEta_Ch  = Ch_eff;
            inverterEta_Dis = Disch_eff;
        else
            error([mfilename('fullpath') ': Battery Voltage for Inverter method LUT must be in the range of 600 V DC to 750 V DC.'])
        end
        
    %% constant
    % Input eta is transformed to mean value.
    case('constant')
        inverterEta = 0.95;
        
        
    %% default
    % error is given for non-existing choice of method
    otherwise
        error([mfilename('fullpath') ': No power electronics efficiency method specified. Please choose method to determine inverter efficiency.'])
        
        
end % end switch

% show chosen inverter method in command window.
disp([mfilename ': <strong>', inverterMethod, '</strong>'])

end % end function
