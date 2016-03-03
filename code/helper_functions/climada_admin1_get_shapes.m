function admin1_shape_selection = climada_admin1_get_shapes(admin0_name,admin1_name)
% climada select shapes that belong to one or more admin1_name
% MODULE:
%   climada/code/helper_functions
% NAME:
%   climada_admin1_get_shapes
% PURPOSE:
%   Get a selection of admin1_shapes based on admin1_name or select on a
%   map. If you select the admin1 on the map, press "Enter" in the command
%   line to complete the selection on the map. Invokes
%   climada_admin1_select_on_map. Hint: If admin1_name is 'all', the entire
%   admin1_shape is returned.
% CALLING SEQUENCE:
%   admin1_shape_selection = climada_admin1_get_shapes(admin0_name,admin1_name)
% EXAMPLE:
%   admin1_shape_selection = climada_admin1_get_shapes;
%   admin1_shape_selection = climada_admin1_get_shapes('Vietnam');
%   admin1_shape_selection = climada_admin1_get_shapes('Vietnam','Y??n B??i');
%   admin1_shape_selection = climada_admin1_get_shapes('Vietnam',{'VNM-5483' 'VNM-458'});
%   admin1_shape_selection = climada_admin1_get_shapes('','all'); % get all admin1_shapes
% INPUTS:
%   admin0_name: the country name, either full or ISO3
%       > If empty, a list dialog lets the user select (default)
%   admin1_name: or admin1_code, if passed on, do not prompt for admin1 name
%       > If empty, a list dialog lets the user select (default), if is set
%       to 'all', the admin1_shape is returned. 
% OPTIONAL INPUT PARAMETERS:
%   none
% OUTPUTS:
%   admin1_shape_selection: shape file (admin1_shapes) with selected admin1 only
% MODIFICATION HISTORY:
% Lea Mueller, muellele@gmail.com, 20160224, init
% Lea Mueller, muellele@gmail.com, 20160229, add functionality 'all' to return the entire admin1_shape set
% Lea Mueller, muellele@gmail.com, 20160229, move to climada/helper_functions, rename to climada_admin1_get_shapes
%-

admin1_shape_selection = []; % init

global climada_global
if ~climada_init_vars,return;end % init/import global variables

% poor man's version to check arguments
% and to set default value where  appropriate
if ~exist('admin0_name','var'),admin0_name=[];end
if ~exist('admin1_name','var'),admin1_name=[];end

% locate the module's (or this code's) data folder (usually  afolder
% 'parallel' to the code folder, i.e. in the same level as code folder)
% module_data_dir=[fileparts(fileparts(mfilename('fullpath'))) filesep 'data'];


% PARAMETERS
% locate the module's data
module_data_dir = [fileparts(fileparts(mfilename('fullpath'))) filesep 'data'];
module_data_dir = [climada_global.modules_dir filesep 'country_risk' filesep 'data'];

% admin0 and admin1 shap files (in climada module country_risk):
admin0_shape_file = climada_global.map_border_file; % as we use the admin0 as in next line as default anyway
% read admin0 (country) shape file (we need this in any case)
if ~exist(admin0_shape_file,'file')
    fprintf('Admin0 file not found. Please check.\n \t%s\n', admin0_shape_file);
    return
end   
admin0_shapes = climada_shaperead(admin0_shape_file);
admin1_shape_file = [module_data_dir filesep 'ne_10m_admin_1_states_provinces' filesep 'ne_10m_admin_1_states_provinces.shp'];
if ~exist(admin1_shape_file,'file')
    fprintf('Admin1 file not found. Please check.\n \t%s\n', admin1_shape_file);
    return
end
admin1_shapes = climada_shaperead(admin1_shape_file); % read admin1 shape file

if strcmp(admin1_name,'all'); admin1_shape_selection = admin1_shapes; return; end

% plot the map the select admin1 with the mouse
if isempty(admin1_name)
    listbox = climada_admin1_select_on_map(admin0_name,admin0_shapes,admin1_shapes);
    str = input('Press enter when you have selected one or multiple admin1 on the map. Press q to quit. [Enter]:');
    if isempty(str); str = 'Y'; end
    if strcmp(str,'q'), return; end
    try
        admin1_name = get(listbox,'UserData'); % use to identify the selected admin1_name
    catch
        fprintf('No admin1 selected.\n')
        admin1_name = ''; return
    end
end

% find the selected admin1 in admin1_shapes
list_admin1_name = {admin1_shapes.name}; %admin1_name_list
is_selected = ismember(list_admin1_name,admin1_name);

% look also in the code, if admin1_code (i.e. VNM-5483) 
% instead of admin1 name is given
if ~any(is_selected) 
    list_admin1_code = {admin1_shapes.adm1_code}; 
    is_selected = ismember(list_admin1_code,admin1_name);
end

if ~any(is_selected), fprintf('%s not found\n',admin1_name); end
    
% cut out the selected shapes from the longlist of all admin1
admin1_shape_selection = admin1_shapes(is_selected);


    

return




