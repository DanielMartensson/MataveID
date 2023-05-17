% Octave does not support the import statement.
% MATLAB import statement documentation: https://www.mathworks.com/help/releases/R2023a/matlab/ref/import.html?s_tid=doc_srchtitle
% Because Octave does not support the import statement, every call to a file in a package must be converted to
% mc.function.

clc; clear; close all;

% Get the Matavecontrol m files
mcFiles = struct2table(dir(fullfile("..","Matavecontrol","sourcecode","+mc","*.m")));
mcFiles.name = string(mcFiles.name);
mifles.folder = string(mcFiles.folder);

[~,mcFunctionList] = fileparts(mcFiles.name);

% Get the Mataveid m file list
sourceCodeFiles = struct2table(dir(fullfile("examples","*.m")));
sourceCodeFiles.name = string(sourceCodeFiles.name);
sourceCodeFiles.folder = string(sourceCodeFiles.folder);
[~,midFunctionList] = fileparts(sourceCodeFiles.name);

% Loop over the Matavid m files
for i = 1:size(sourceCodeFiles,1)
  filePath = fullfile(sourceCodeFiles.folder(i), sourceCodeFiles.name(i));
  text = fileread(filePath);
  % loop over the Matavecontrol m files
  for j = 1:size(mcFiles,1)
    replacementExpression = "mc."+ mcFunctionList(j) +"(";
      expression = "(?<=[^a-zA-Z0-9_])" + mcFunctionList(j) + "\s*(";
      text = regexprep(text, expression, replacementExpression);
  end
  fileId = fopen(filePath,'w');
  fprintf(fileId, "%s",text);
  fclose(fileId);
end