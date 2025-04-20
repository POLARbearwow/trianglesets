function triangleset = generate_periodic_triangleset(L)
    vertex_grid = zeros(L);
    for row = 1:L-1
        start_val = (row-1)*(L-1) + 1;
        vertex_grid(row, 1:L-1) = start_val : start_val+L-2;
    end
    vertex_grid(L, :) = vertex_grid(1, :);    
    vertex_grid(:, L) = vertex_grid(:, 1);     
    
    
    disp('顶点矩阵：');
    disp(vertex_grid);
    fprintf('\n');

   
    triangleset = [];
    for i = 1:L-1
        for j = 1:L-1
            a = vertex_grid(i, j);
            b = vertex_grid(i, j+1);
            c = vertex_grid(i+1, j);
            d = vertex_grid(i+1, j+1);

            triangleset = [triangleset; 
                          a, b, c;   
                          b, d, c];  
        end
    end
   
    fprintf('三角形总数：%d\n', size(triangleset, 1));
end