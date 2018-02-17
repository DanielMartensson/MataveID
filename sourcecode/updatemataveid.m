% Update the whole mataveid library by downloading from GitHub
% Author: Daniel Mårtensson, Februari 2018

function [retval] = updatemataveid(varargin)
  % Get the current working dictionary
  currentFolder = pwd;
  
  % Just update matavecontrol
  A = what('mataveid'); % Importat that it must stand 'mataveid'. Nothing else!
  
  % Get the information about where the files are
  path = A.path; % File path
  
  % Go to path dictionary
  cd(path);
  
  % Downloading listOfFunctions
  urlwrite('https://raw.githubusercontent.com/DanielMartensson/mataveid/master/listOfFunctions', 'listOfFunctions');
  
  % Read the listOfFunctions
  fid = fopen('listOfFunctions');
  txt = textscan(fid, '%s', 'delimiter', '\n'); % Importat to have the delimiter = '\n'
  % Remove this double struct
  fileList = txt{1,1};
  
  % Downloading all the other files
  [m, n] = size(fileList);
  for i = 1:m
    % Downloading
    nameOfFile = fileList{i, 1};
    URL = strcat('https://raw.githubusercontent.com/DanielMartensson/mataveid/master/sourcecode/', nameOfFile)
    [saveplace, Success] = urlwrite(URL, nameOfFile);
    saveplace
    Success
  end
  
  disp('Mataveid is updated!')
  
  % Get to the current working dictionary
  cd(currentFolder);
  
end
