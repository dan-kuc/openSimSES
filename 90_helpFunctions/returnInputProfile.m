%%  returnInputProfile
%   Load, check and return input profile specified by file name and folder.Data
%   Returns selected profile by name, number or type of data. 
%   Returns all profiles if there is no selection
%   Input: 
%       Profile name
%       Profile number
%       Profile type name
%       Profile file name
%       Local file folder
%       Server path for profile file search
%       verifyHashCode flag for verifying function
%   Output:
%       profile [-] Data profile of selected file and specific profile choice
%   Function owner:   Maik Naumann
%   Creation date:    08.04.2016

function profile = returnInputProfile( varargin )

%% Input parsing
p = inputParser;
defVal = NaN;

addParameter(p, 'localFilesFolder',     defVal)
addParameter(p, 'profileFileName',      defVal)
addParameter(p, 'profileServerPath',    defVal)
addParameter(p, 'profileNumber',        defVal)
addParameter(p, 'profileTypeName',      defVal)
addParameter(p, 'verifyHashCode',       defVal)

parse(p,varargin{:});

localFilesFolder    = p.Results.localFilesFolder;
profileFileName     = p.Results.profileFileName;
profileServerPath   = p.Results.profileServerPath;
profileNumber       = p.Results.profileNumber;
profileTypeName     = p.Results.profileTypeName;
verifyHashCode      = p.Results.verifyHashCode;

%% Search for profile in given local file folder or server path

% Check if profile folder exists. If not, create folder
if ~exist(localFilesFolder,'dir') 
    mkdir(localFilesFolder); 
end

% Extend filename with .mat if not given in input
if ~strcmp(profileFileName(end-3:end),'.mat')
    profileFileName = [profileFileName, '.mat'];
end

% Search for profile first in given local file folder 
fileFolderList = subdir(localFilesFolder);
for idx_fileFolderList = 1:length(fileFolderList(:,1))
    if(strcmp(fileFolderList(idx_fileFolderList).name(max(1,end-length(profileFileName)+1):end), profileFileName))
        % If load profile already exits, load data
        fileData = load(fileFolderList(idx_fileFolderList).name);
        break;
    end
end

% If file not found in local file folder, download file from given server path
if(~exist('fileData','var'))
    % Open Matlab web browser with path to the load profile for download
    web([profileServerPath,profileFileName]);
    % Open dialog for user instruction and to control when download is finished
    waitfor(helpdlg(['Selected load profile, ''' profileFileName,''' not found on local path ''01_ProfileData''. ', newline,...
                     'The profiles can be downloaded from Bitbucket within the Matlab web browser, after the login with your Bitbucket account. ', newline, ... 
                     'After the login, please indicate the folder path (e.g. ''01_ProfileData'') where the load profile is going to be downloaded. ', newline, ...
                     'Wait for the download and press ''OK'' when download is finished.'], 'Download load profile'));
    % Wait 5 seconds until download should be finished if user possibly did
    % not wait sufficient time
    pause(10)
    % Close Matlab web browser
    com.mathworks.mlservices.MatlabDesktopServices.getDesktop.closeGroup('Web Browser');
    % Load data from downloaded file
    try
        fileData = load([localFilesFolder,'\', profileFileName]);     
    catch
        error([profileFileName, ': Download of load profile did not work or was saved in a wrong path']);
    end
end

% Check if profile file was loaded, copied and exists now in local folder
if(~exist('fileData','var'))
    error([profileFileName, ': Input file cannot be not found or does not exist']);
else
    
%% Select profile by input

% Check if data format complies with necessary data structure and check if hash value of data is correct
if(isfield(fileData,'Hash_value_of_struct') && isfield(fileData, 'Data'))
    if(verifyHashCode)
        verifyDataHashCode(fileData.Data, fileData.Hash_value_of_struct, profileFileName)
    end
    Data = fileData.Data;
    clearvars -except Data profileTypeName profileNumber profileFileName
else
    warning([profileFileName, ': Input file does not have correct file structure -> Returning complete file data']);
    profile = fileData;
    return;
end

% Select profile by number
number_of_data = str2double(Data.Number_of_data);

if(~isnan(profileNumber))
    if(isfield(Data, ['Profile_', num2str(profileNumber)]))
        profile = eval(['Data.Profile_', num2str(profileNumber)]);
    else
        error([profileFileName,': Profile_', num2str(profileNumber),' does not exist']);
    end
    if(~isnan(profileTypeName))
        warning([profileFileName, ': Selection of profile by name and number not valid']);
    end   
% Select profile by name
elseif(any(~isnan(profileTypeName)))
    % Check if only one type of data exists
    if(isfield(Data, 'Type_of_data') && number_of_data > 1)
        warning([profileFileName, ': There exist more than one data profile but with same name of data type',...
            '-> No selection by profile type name possible -> Returning "Profile_1"']);
        profile = Data.Profile_1;
    else  
        for idx_profileName = 1:number_of_data
            typeOfDataName = ['Type_of_data_', num2str(idx_profileName)];
            if(strcmp(profileTypeName, eval(['Data.',typeOfDataName])))
                profile = eval(['Data.Profile_', num2str(idx_profileName)]);
                break;
            end
        end
    end
    
% If no profile was selected, check if input file has multiple input profiles and assign them correctly
else
    if(number_of_data == 1)
        profile = Data.Profile;
    else
        warning([profileFileName, ': There exist more than one data profile -> Returning all profiles']);
        profile = zeros(length(Data.Profile_1), number_of_data);
        for idx_Profile = 1:number_of_data
            profile(:, idx_Profile) = eval(['Data.Profile_', num2str(idx_Profile)]);
        end
    end
end

% Convert profile data to double
profile = double(profile);

end