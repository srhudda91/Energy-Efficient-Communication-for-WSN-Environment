classdef AlgoManager < handle
    %{
            
            This class is responsible for managing state information at any given point in time. It provides methods that allow accessing and 
            modifying the state as needed. Whenever a change in state occurs, the class checks if switching is required and 
            switches to the best available algorithm.
                
    %}
    properties (Access = private)
        i_state = [1 1] ;
        i_old_state = [1 1];
        current_algo=9;
        algos={'ANU', 'QTL', 'Midori', 'Rectangle', 'Present', 'HIGHT', 'KLEIN', 'LBlock', 'Lilliput', 'LED'};
        security_priority = [2,1,5,7,8,10,6,9,4,3];
        energy_priority = [7,4,10,9,6,3,2,1,5,8]; %{8,7,6,2,9,5,1,10,4,3}; 
        % visited = zeros(1,10);
    end
    properties(Dependent)
        state;

    end

    
    methods
        function algo = getCurrentAlgo(obj)
            %{
            
            Output :
                algo -> ID of the current algorithm
           
        %}
            algo = obj.current_algo;
        end
        function set.state(obj, value)
            if ~isequal(obj.i_state, value)
                obj.i_old_state = obj.i_state;
                obj.i_state = value;
                obj.switch_algo();

            end
        end
        %{
            
            Output :
                value -> Current State
           
        %}
        function value = get.state(obj)
            value = obj.i_state;
        end
        
        function  switch_algo(obj)
            %{
            
            This function first checks if there is a change in state. If a
            state change is detected, it initializes the cost matrix with zeros.Cost is the difference between an algorithm and the current algorithm.
            Next, it verifies whether the security status has changed.If a change in security status is found, it calculates the associated security cost
            and adds it to the cost matrix. Similarly,it checks for any changes in the device status. If a change is detected, the function calculates 
            the cost related to the device and adds it to the cost matrix. After updating the cost matrix with both security and device costs, 
            the function selects the algorithm with the lowest cost and sets it as the current algorithm.
        %}
            [memAvail,~] = memory;
            isChanged = false;
            weightedArray = zeros(1,10);
            if (obj.i_state(1) == 0)
                disp("Algorithm Run by Security");
                % obj.visited(obj.current_algo) = 1;
                weightedArray = obj.getPriority(obj.security_priority,obj.current_algo);
                obj.i_state(1)=1;
                isChanged = true;
            end
            if (obj.i_state(2) == 0)
                 if (obj.current_algo == find(obj.energy_priority == min(obj.energy_priority),1))
                     disp("Already Most Optimized");
                     obj.i_state(2)=1;
                 else
                     disp("Algorithm Run by Energy");
                     weightedArray = weightedArray + obj.getPriority(obj.energy_priority,obj.current_algo);
                     obj.i_state(2)=1;
                     isChanged = true;
                  end
             end
                if isChanged
                    disp(weightedArray);
                    bestAlgo = find(weightedArray == min(weightedArray),1);
                    obj.current_algo = bestAlgo;
                    [memAfter,~] = memory;
                    disp(["Memory Used: " (memAfter.MemUsedMATLAB  - memAvail.MemUsedMATLAB) ," Bytes"]);
                end
        end
        

        function priority = getPriority(obj,order_array,curAlgo)
           %{
            Input : 
                order_array -> Weight Matrix for a parameter(Device or Security).
                curAlgo -> Current algorithm
              
            Output :
                priority -> Cost Matrix
            This function takes order_array, which represents the weight matrix for a specific parameter such as Device or Security, and curAlgo, 
            which is the current algorithm, as input.The output of the function is priority, which represents the cost matrix.The function begins by 
            calculating the cost of each algorithm by determining the difference between the current algorithm and every other algorithm in the weight matrix. After computing these differences,
            it applies an additional factor to penalize algorithms with higher or equal weights, ensuring that lower-weighted algorithms are prioritized.
            Finally, the function returns the resulting cost matrix, which reflects the computed costs for all algorithms based on the given parameters.
               
        %}
            curP = curAlgo;
            n = 10;
            priority = zeros(1, n); 
            factor = 21;
            for i = 1:n
                
                w = order_array(curP) - order_array(i);
                if (w > 0)
                    priority(i) =  w;
                else
                    priority(i) = (factor) + w;
                end
            end
        end
    end
end