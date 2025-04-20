classdef BoundaryChecker
    properties
        l
        lr_boundary  
        tb_boundary  
    end

    methods
        function obj = BoundaryChecker(l)
            obj.l = l;
            n_values = 0:(l-2);
            obj.lr_boundary = n_values * (l - 1) + 1;
            obj.lr_boundary = [obj.lr_boundary, 1];
            disp(obj.lr_boundary);
            
            obj.tb_boundary = [1:(l-1), 1];
            disp(obj.tb_boundary);
        end

        function [isLeft, isRight, isTop, isBottom, isPermeate] = checkTriangles(obj, triangles)
            isLeft = false;
            isRight = false;
            isTop = false;
            isBottom = false;
            isPermeate = false;

            for i = 1:size(triangles, 1)
                a = triangles(i, 1);
                b = triangles(i, 2);
                c = triangles(i, 3);
                vertices = [a, b, c];
                
                
                diff = max(vertices) - min(vertices);
                
                % 检查左右边界
                if any(ismember(vertices, obj.lr_boundary))
                    if ~isLeft && (diff == obj.l || diff == obj.l^2 - 3*obj.l + 2)
                        isLeft = true;
                    end
                    if ~isRight && (diff == obj.l-1 || diff == (obj.l-1)^2-1)
                        isRight = true;
                    end
                end
                
                % 检查上下边界
                if any(ismember(vertices, obj.tb_boundary))
                    if ~isTop && diff <= obj.l
                        isTop = true;
                    end
                    if ~isBottom && diff > obj.l
                        isBottom = true;
                    end
                end
                
                % 贯穿判断
                isPermeate = (isLeft && isRight) || (isTop && isBottom);
                
                % 提前退出优化
                if  isPermeate
                    break;
                end
            end
        end
    end
end