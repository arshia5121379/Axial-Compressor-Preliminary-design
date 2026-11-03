function writeValueToTxt(fid, fieldName, value, depth)
% Recursive writer for structures, structure arrays, cells and numeric data.
% Numeric vectors/matrices are written as indexed tables in tab-separated form.

    indent = repmat(' ', 1, 2*depth);
    fprintf(fid, '\n%s------------------------------------------------------------\n', indent);
    fprintf(fid, '%s%s\n', indent, fieldName);
    fprintf(fid, '%s------------------------------------------------------------\n', indent);

    if isempty(value)
        fprintf(fid, '%s[Empty]\n', indent);
        return;
    end

    if isstruct(value)
        fprintf(fid, '%sStructure size: %s\n', indent, mat2str(size(value)));
        for n = 1:numel(value)
            if numel(value) > 1
                fprintf(fid, '\n%s[%s element %d]\n', indent, fieldName, n);
            end
            names = fieldnames(value(n));
            for j = 1:numel(names)
                nm = names{j};
                try
                    writeValueToTxt(fid, nm, value(n).(nm), depth + 1);
                catch ME
                    fprintf(fid, '%s  %s: [Could not export: %s]\n', indent, nm, ME.message);
                end
            end
        end

    elseif isnumeric(value) || islogical(value)
        fprintf(fid, '%sClass: %s | Size: %s\n', indent, class(value), mat2str(size(value)));
        if isscalar(value)
            fprintf(fid, '%sValue\t%.16g\n', indent, double(value));
        elseif isvector(value)
            fprintf(fid, '%sIndex\tValue\n', indent);
            for n = 1:numel(value)
                fprintf(fid, '%s%d\t%.16g\n', indent, n, double(value(n)));
            end
        else
            fprintf(fid, '%sRow\tColumn\tValue\n', indent);
            for r = 1:size(value,1)
                for c = 1:size(value,2)
                    fprintf(fid, '%s%d\t%d\t%.16g\n', indent, r, c, double(value(r,c)));
                end
            end
        end

    elseif ischar(value)
        if size(value,1) > 1
            fprintf(fid, '%sCharacter array:\n%s\n', indent, value);
        else
            fprintf(fid, '%s%s\n', indent, value);
        end

    elseif isstring(value)
        fprintf(fid, '%s%s\n', indent, strjoin(cellstr(value(:)), ', '));

    elseif iscell(value)
        fprintf(fid, '%sCell array size: %s\n', indent, mat2str(size(value)));
        for n = 1:numel(value)
            writeValueToTxt(fid, sprintf('%s{%d}', fieldName, n), value{n}, depth + 1);
        end

    elseif isa(value, 'function_handle')
        fprintf(fid, '%s[Function handle: %s]\n', indent, func2str(value));

    elseif istable(value)
        fprintf(fid, '%sTable size: %d rows x %d columns\n', indent, height(value), width(value));
        try
            fprintf(fid, '%s', evalc('disp(value)'));
        catch
            fprintf(fid, '%s[Table display unavailable]\n', indent);
        end

    else
        fprintf(fid, '%s[Value of class %s not expanded]\n', indent, class(value));
        try
            fprintf(fid, '%s\n', evalc('disp(value)'));
        catch
        end
    end
end
