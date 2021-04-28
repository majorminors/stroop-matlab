function yes = hasdaq()
yes = false;

try
    D = daq.getDevices;
    yes = ~isempty(D) && D.isvalid && any(strcmp({D.Vendor.ID},'ni')) && ...
            D.Vendor.isvalid && D.Vendor.IsOperational;
catch err
    if ~strcmp(err.identifier,'MATLAB:undefinedVarOrClass')
        rethrow(err);
    end
end

