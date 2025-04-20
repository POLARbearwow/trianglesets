function [triangleset, vertex_grid] = generate_adaptive_triangleset(L, is_periodic)
    % 生成自适应边界条件的三角形集合
    % 输入：
    %   L - 网格尺寸
    %   is_periodic - 是否为周期性边界
    % 输出：
    %   triangleset - 三角形集合
    %   vertex_grid - 顶点编号矩阵
    
    % ========== 顶点网格生成 ==========
    if is_periodic
        % 周期性边界顶点生成
        vertex_grid = zeros(L);
        for row = 1:L-1
            start_val = (row-1)*(L-1) + 1;
            vertex_grid(row, 1:L-1) = start_val : start_val+L-2;
        end
        % 应用周期性边界条件
        vertex_grid(L, :) = vertex_grid(1, :);
        vertex_grid(:, L) = vertex_grid(:, 1);
        
        % 记录原始顶点（不含周期映射）
        original_grid = zeros(L);
        for row = 1:L-1
            start_val = (row-1)*(L-1) + 1;
            original_grid(row, 1:L-1) = start_val : start_val+L-2;
        end
        original_grid(L, L) = (L-1)^2 + 1; % 补全右下角
    else
        % 开放边界顶点生成
        vertex_grid = reshape(1:L^2, L, L)';
        original_grid = vertex_grid; % 开放边界原始矩阵与显示矩阵相同
    end
    
    % ========== 显示顶点信息 ==========
    disp('当前顶点矩阵：');
    disp(vertex_grid);
    fprintf('原始顶点编号：\n');
    disp(original_grid);
    fprintf('\n');
   
    % ========== 三角形生成逻辑 ==========
    triangleset = [];
    for row = 1:L-1
        for col = 1:L-1
            % 获取当前单元四个顶点
            a = vertex_grid(row, col);
            b = vertex_grid(row, col+1);
            c = vertex_grid(row+1, col);
            d = vertex_grid(row+1, col+1);
            
            % 固定顺序生成两个三角形
            triangleset = [triangleset;
                         a, b, c;   % 右上三角形
                         b, d, c];  % 左下三角形
        end
    end
    
    % 显示生成信息
    boundary_type = {'开放边界', '周期性边界'};
    fprintf('%s生成完成\n', boundary_type{is_periodic+1});
    fprintf('网格尺寸：%dx%d\n', L, L);
    fprintf('有效顶点数：%d\n', numel(unique(vertex_grid(:))));
    fprintf('三角形总数：%d\n\n', size(triangleset,1));
end