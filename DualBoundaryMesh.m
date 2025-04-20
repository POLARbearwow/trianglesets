classdef DualBoundaryMesh
    % 双边界网格生成器（开放+周期性边界）
    
    properties
        L                   % 网格尺寸
        open_grid           % 开放边界顶点矩阵
        periodic_grid       % 周期性边界顶点矩阵
        coord_map           % 开放顶点坐标映射表
        dual_map            % 周期性顶点坐标映射表
        open_tri            % 开放边界三角形集合
        periodic_tri        % 周期性边界三角形集合
    end
    
    methods
        function obj = DualBoundaryMesh(L)
            % 构造函数：初始化网格和三角形集合
            obj.L = L;
            obj = obj.generateOpenGrid();
            obj = obj.generatePeriodicGrid();
            obj = obj.generateDualTriangles();
        end
        
        function obj = generateOpenGrid(obj)
            % 生成开放边界网格
            obj.open_grid = reshape(1:obj.L^2, obj.L, obj.L)';
            obj.coord_map = containers.Map('KeyType','int32','ValueType','any');
            
            for i = 1:obj.L
                for j = 1:obj.L
                    obj.coord_map(obj.open_grid(i,j)) = [i, j];  
                end
            end
            
            disp('===== 开放边界顶点矩阵 =====');
            disp(obj.open_grid);
        end
        
        function obj = generatePeriodicGrid(obj)
    % 生成周期性边界网格（正确循环映射）
    base_grid = zeros(obj.L);
    for row = 1:obj.L-1
        start_val = (row-1)*(obj.L-1) + 1;
        base_grid(row, 1:obj.L-1) = start_val : start_val+obj.L-2;
    end
    
    % 列周期性：最后一列映射到第一列
    base_grid(:, obj.L) = base_grid(:, 1);
    % 行周期性：最后一行映射到第一行
    base_grid(obj.L, :) = base_grid(1, :);
    
    obj.periodic_grid = base_grid;
    
    % 构建双坐标映射（开放网格的坐标）
    obj.dual_map = containers.Map('KeyType','int32','ValueType','any');
    for i = 1:obj.L
        for j = 1:obj.L
            p_num = base_grid(i, j);
            % 计算开放网格的真实坐标（考虑周期性循环）
            i_open = i;
            j_open = j;
            if i == obj.L  % 处理行周期性
                i_open = 1;
            end
            if j == obj.L  % 处理列周期性
                j_open = 1;
            end
            open_coord = [i_open, j_open];
            if isKey(obj.dual_map, p_num)
                obj.dual_map(p_num) = [obj.dual_map(p_num); open_coord];
            else
                obj.dual_map(p_num) = open_coord;
            end
        end
    end
    
    disp('===== 周期性边界顶点矩阵 =====');
    disp(obj.periodic_grid);
end
        
        function obj = generateDualTriangles(obj)
            % 生成双边界三角形集合
            obj.open_tri = [];
            obj.periodic_tri = [];
            
            for i = 1:obj.L-1
                for j = 1:obj.L-1
                    % 开放三角形
                    o_a = obj.open_grid(i,j);
                    o_b = obj.open_grid(i,j+1);
                    o_c = obj.open_grid(i+1,j);
                    o_d = obj.open_grid(i+1,j+1);
                    obj.open_tri = [obj.open_tri; o_a o_b o_c; o_b o_d o_c];
                    
                    % 周期性三角形
                    p_a = obj.periodic_grid(i,j);
                    p_b = obj.periodic_grid(i,j+1);
                    p_c = obj.periodic_grid(i+1,j);
                    p_d = obj.periodic_grid(i+1,j+1);
                    obj.periodic_tri = [obj.periodic_tri; p_a p_b p_c; p_b p_d p_c];
                end
            end
        end
        
        function open_vertices = periodic2openCoords(obj, periodic_tri)
    % 坐标转换方法：返回开放顶点编号
    open_vertices = zeros(1, 3);
    for k = 1:3
        v = periodic_tri(k);
        if ~isKey(obj.dual_map, v)
            error('顶点 %d 不存在于映射表', v);
        end
        coords = obj.dual_map(v);
        % 选择第一个坐标（已通过generatePeriodicGrid确保正确循环映射）
        i_open = coords(1, 1);
        j_open = coords(1, 2);
        open_vertex = obj.open_grid(i_open, j_open);
        open_vertices(k) = open_vertex;
    end
end
    end
end