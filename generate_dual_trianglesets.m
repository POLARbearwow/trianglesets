function [periodic_tri, open_tri] = generate_dual_trianglesets(L)
    % 主函数代码（调用下方的局部函数）
    [open_grid, coord_map] = generate_open_grid(L);
    [periodic_grid, dual_map] = generate_periodic_grid(open_grid, L);
    [periodic_tri, open_tri] = generate_dual_triangles(open_grid, periodic_grid, L);
    % cross_flags = check_periodic_crossing(periodic_tri, dual_map, L);
end

%% 基础开放网格生成函数
function [grid, coord_map] = generate_open_grid(L)
    % 生成开放边界顶点网格及坐标映射
    % 输出：
    %   grid - LxL开放网格，顶点按行优先编号
    %   coord_map - 顶点编号到坐标的映射 (key: 顶点号, value: [i,j])
    
    grid = reshape(1:L*L, L, L)';
    coord_map = containers.Map('KeyType','int32','ValueType','any');
    
    for i = 1:L
        for j = 1:L
            coord_map(grid(i,j)) = [i, j];  
        end
    end

    vertex_grid_open = flip(grid, 1);

    disp('Open Boundary Vertex Matrix:');
    disp(vertex_grid_open);
    fprintf('\n');
end

%% 周期性网格生成函数（修正版）
function [periodic_grid, dual_map] = generate_periodic_grid(open_grid, L)
    % 生成周期性网格及双坐标映射
    % 输入：
    %   open_grid - 基础开放网格
    %   L - 网格尺寸
    % 输出：
    %   periodic_grid - LxL周期性网格  
    %   dual_map - 周期性顶点到开放坐标的映射 (key: 顶点号, value: nx2坐标矩阵)
    
    %% 生成基础周期性网格（未翻转）
    base_grid = zeros(L);
    for row = 1:L-1
        start_val = (row-1)*(L-1) + 1;
        base_grid(row, 1:L-1) = start_val : start_val+L-2;
    end
    
    % 应用周期性边界
    base_grid(L, :) = base_grid(1, :);    % 行周期性
    base_grid(:, L) = base_grid(:, 1);    % 列周期性
    
    %% 创建最终网格（带翻转）
    periodic_grid = flip(base_grid, 1);   % 上下翻转
    
    %% 构建双坐标映射系统
    dual_map = containers.Map('KeyType','int32','ValueType','any');
    
    % 遍历翻转后的网格坐标
    for i = 1:L
        for j = 1:L
            % 计算翻转前的原始坐标
            orig_i = L - i + 1;  % 翻转补偿
            
            % 获取对应的开放网格顶点编号
            p_num = base_grid(orig_i, j);
            
            % 记录当前网格坐标到映射表
            if isKey(dual_map, p_num)
                dual_map(p_num) = [dual_map(p_num); i, j];
            else
                dual_map(p_num) = [i, j];
            end
        end
    end
    
    %% 显示结果
    disp('Periodic Boundary Vertex Matrix:');
    disp(periodic_grid);
    fprintf('\n');
end

%% 双边界三角形生成函数
function [periodic_tri, open_tri] = generate_dual_triangles(open_grid, periodic_grid, L)
    % 生成双边界三角形集合
    % 输入：
    %   open_grid - 开放边界网格
    %   periodic_grid - 周期性边界网格  
    %   L - 网格尺寸
    % 输出：
    %   periodic_tri - 周期性边界三角形集合 [2*(L-1)^2 x 3]
    %   open_tri - 开放边界三角形集合 [2*(L-1)^2 x 3]
    
    periodic_tri = [];
    open_tri = [];
    
    % 遍历所有单元格
    for i = 1:L-1
        for j = 1:L-1
            %% 开放边界三角形
            % 当前单元的四个顶点
            o_a = open_grid(i,j);
            o_b = open_grid(i,j+1);
            o_c = open_grid(i+1,j);
            o_d = open_grid(i+1,j+1);
            
            % 添加两个三角形
            open_tri = [open_tri; 
                       o_a, o_b, o_c;  % 右上三角
                       o_b, o_d, o_c]; % 左下三角
            
            %% 周期性边界三角形
            % 当前单元的四个顶点
            p_a = periodic_grid(i,j);
            p_b = periodic_grid(i,j+1);
            p_c = periodic_grid(i+1,j);
            p_d = periodic_grid(i+1,j+1);
            
            % 添加两个三角形 
            periodic_tri = [periodic_tri;
                           p_a, p_b, p_c;
                           p_b, p_d, p_c];
        end
    end
end

function open_coords = periodic2open_coords(periodic_tri, dual_map, coord_map)
    % 将周期性三角形转换为开放边界坐标
    % 输入：
    %   periodic_tri - 周期性三角形顶点列表 (1×3数组)
    %   dual_map     - 周期性顶点坐标映射表
    %   coord_map    - 开放顶点坐标映射表
    % 输出：
    %   open_coords  - 对应的开放坐标系 (3×2矩阵)

    open_coords = zeros(3,2);
    
    for k = 1:3
        v = periodic_tri(k);
        
        % 获取周期性顶点所有可能坐标
        if ~isKey(dual_map, v)
            error('顶点 %d 不存在于映射表中', v);
        end
        periodic_coords = dual_map(v);
        
        % 选择最小编号的开放坐标（可根据需求修改选择策略）
        % 示例策略：选择第一个出现的坐标
        selected_coord = periodic_coords(1,:);
        
        % 转换为开放坐标系
        orig_i = selected_coord(1);
        orig_j = selected_coord(2);
        open_v = v; % 这里假设周期性编号与开放编号直接对应
        
        % 验证坐标有效性
        if ~isKey(coord_map, open_v)
            error('开放顶点 %d 坐标不存在', open_v);
        end
        open_coords(k,:) = coord_map(open_v);
    end
end