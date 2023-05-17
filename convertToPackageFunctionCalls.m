% Octave does not support the import statement.
% MATLAB import statement documentation: https://www.mathworks.com/help/releases/R2023a/matlab/ref/import.html?s_tid=doc_srchtitle
% Because Octave does not support the import statement, every call to a file in a package must be converted to
% mc.function.

clc; clear; close all;

package = "Mid";
mfiles = struct2table(dir(fullfile("sourcecode","+" + package,"*.m")));
mfiles.name = string(mfiles.name);
mifles.folder = string(mfiles.folder);

[~,functionList] = fileparts(mfiles.name);

for i = 1:size(mfiles,1)
  filePath = fullfile(mfiles.folder(i), mfiles.name(i));
  text = fileread(filePath);
  for j = 1:size(mfiles,1)
    replacementExpression = package + "."+ functionList(j) +"(";
    if i==j
      expression = "(?<!function.+?)(?<=[^a-zA-Z0-9_])" + functionList(j) + "\s*\(";
      text = regexprep(text, expression, replacementExpression,"dotexceptnewline");
    else
      expression = "(?<=[^a-zA-Z0-9_])" + functionList(j) + "\s*(";
      text = regexprep(text, expression, replacementExpression);
    end
    
    
  end
  fileId = fopen(filePath,'w');
  fprintf(fileId, "%s",text);
  fclose(fileId);
end