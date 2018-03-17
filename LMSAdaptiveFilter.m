channel1 = [1+1*1i 0.2+0.2*1i -0.4-0.4*1i 0.3+0.3*1i 0.2+0.2*1i -0.1-0.1*1i];
channel2 = [1 0.2 -0.4 0.3 0.2 -0.1];
channel3 = [1j 0.2j -0.4j 0.3j 0.2j -0.1j];
lmsFilter(channel1,25,0.0001,10,300,30,100);

% the parameters of the functionare c,SNR,u,M,N,T,P
% c is the channel filter
% SNR is the signal to noise ratio
% u is mew, in this context it is step size of the adaptive filter
% M is the length of the adaptive filter
% N is the number of samples that with go throug the system before the program ends
% P is the number of trials that you would like to run in parrallel for demonstration purposes


function y = lmsFilter(c,SNR,u,M,N,T,P)
    CLENGTH = length(c);
    
    a = 10^(SNR/20)/sqrt(2);
    
    training = true;

    noise = zeros(P,N);
    perfectSignal = zeros(P,N);

    for i=1:P
        noiseTemp = (1/sqrt(2))*(randn(1,N)+1*1i*randn(1,N));
        perfectSignalTemp = myInput(a,N);
        for j=1:N
            noise(i,j) = noiseTemp(j);
            perfectSignal(i,j) = perfectSignalTemp(j);
        end
    end

    % testDecisions(P,noise,perfectSignal,a);

    correct = 0;
    notCorrect = 0;

    inputBuffer = zeros(P,M);
    allAdaptedFilters = zeros(P,M);

    aN = zeros(1,P);
       
        xN = zeros(1,P);
        xBuff = zeros(P,M);
        aBuff = zeros(P,CLENGTH);
        aHat = zeros(1,P);
        error = zeros(1,P);
        output = zeros(1,P);

    for i=1:N
        if i == T + 1
            training = false;
        end

        for j=1:P
            %plot perfect SIGNAL HERE

            aN(j) = perfectSignal(j,i);
            
            aBuff(j,1:CLENGTH) = insertToZero(aBuff(j,1:CLENGTH),aN(j));

            xN(j) = aBuff(j,1:CLENGTH)*c' + noise(j,i);

            xBuff(j,1:M) = insertToZero(xBuff(j,1:M),xN(j));
            
    %       noisy signal here

            aHat(j) = xBuff(j,1:M)*allAdaptedFilters(j,1:M)';


            output(j) = decisionMaker(a,aHat(j));

            if training == true
                inputBuffer(j,1:M) = insertToZero(inputBuffer(j,1:M),aN(j));
            else
                inputBuffer(j,1:M) = insertToZero(inputBuffer(j,1:M),output(j));
            end

            error(j) = inputBuffer(j,1) - aHat(j);

            allAdaptedFilters(j,1:M) = allAdaptedFilters(j,1:M) + (u*conj(error(j)))*xBuff(j,1:M);

            if output(j) == aN(j)
                correct = correct + 1;
            else 
                notCorrect = notCorrect + 1;
            end
        end
        errorAvg = mean(error);

    % Real-time Plot    
        if i < T + 1 % training-mode
            if i == 1 % then create err_plot_vector
                err_plot_vector = abs(errorAvg); 
            else % update err_plot_vector
                err_plot_vector = horzcat(err_plot_vector, abs(errorAvg)); 
            end
        else % output-mode
            err_plot_vector = horzcat(err_plot_vector, abs(errorAvg));
        end



        subplot(2,2,1);
        time = 0:1:i-1;
        plot(time, err_plot_vector);
        set(gca, 'YScale', 'log');
        title('Magnitude of Error')
        axis([0 , N, 0, 2*a])
        grid on


        subplot(2,2,2);
        plot(aN, 'o');
        title('Original Input a')
        axis([-2*a, 2*a, -2*a, 2*a])
        grid on


        subplot(2,2,3);
        plot(xN, 'o')
        title('Noisy Input x')
        axis([-2*a, 2*a, -2*a, 2*a])
        grid on


        subplot(2,2,4);
        plot(aHat, 'o')
        title('Filtered Output a hat')
        axis([-2*a, 2*a, -2*a, 2*a])
        grid on

        drawnow;

        pause(0.005)
    end
    
    percentageCorrect = correct/(correct+notCorrect)

end





function y = decisionMaker(a,input)
    allPossibilities = [a+a*1i, a-a*1i, -a+a*1i, -a-a*1i];
    minDistance = 1000000;
    minIndex = 7;
    for i=1:4
        dist = distance(allPossibilities(i),input);
        if dist < minDistance
            minDistance = dist;
            minIndex = i;
        end
    end
    
    y = allPossibilities(minIndex);
    
end


function y = distance(v1,v2)
    y = sqrt((real(v1) - real(v2))^2 + (imag(v1) - imag(v2))^2);
end

function y = insertToZero(a,input) %inserts a value into the 0th index of array
    tempArray = circshift(a,1);
    tempArray(1) = input;
    y = tempArray;
end



function y = myInput(a,N)

    output = [];
    count = 0;

    for i=1:N

        randomNums = rand(1,1)*2 - 1;

        sample = 0;
        if randomNums >= 0.5
            sample = a + a*j;
        elseif randomNums < 0.5 & randomNums >= 0
            sample = a - a*j;
        elseif randomNums > -0.5 & randomNums < 0
            sample = -a + a*j;
        else
            sample = -a - a*j;
        end
        count = count + 1;
        output(count) = sample;

    end
    y = output;

end





