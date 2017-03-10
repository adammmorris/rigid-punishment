clear all
load('replicators_rd.mat')

IND_FAMILIAR = 10;
IND_PARADOXICAL = 21;
IND_NOCONV = 0;

thetaVals = linspace(0, 1, 51);
nThetaVals = length(thetaVals);
nSamplesPerVal = 10;

ys = zeros(nThetaVals, nSamplesPerVal);
xs = zeros(nThetaVals, nSamplesPerVal);
thetas = zeros(nThetaVals, nSamplesPerVal);
correct = zeros(nThetaVals, nSamplesPerVal);
correct2 = zeros(nThetaVals, nSamplesPerVal);

for thisThetaVal = 1:nThetaVals
    for thisSample = 1:nSamplesPerVal
        thetas(thisThetaVal, thisSample) = thetaVals(thisThetaVal);
        ys(thisThetaVal, thisSample) = c(thisThetaVal, thisSample) / sp(thisThetaVal, thisSample);
        xs(thisThetaVal, thisSample) = p(thisThetaVal, thisSample) / s(thisThetaVal, thisSample) - 1;
        
        if outcomes(thisThetaVal, thisSample) == IND_FAMILIAR || outcomes(thisThetaVal, thisSample) == IND_PARADOXICAL
            if thetas(thisThetaVal, thisSample) > ...
                (ys(thisThetaVal, thisSample) / (ys(thisThetaVal, thisSample) + xs(thisThetaVal, thisSample)))
                correct(thisThetaVal, thisSample) = outcomes(thisThetaVal, thisSample) == IND_FAMILIAR;
            else
                correct(thisThetaVal, thisSample) = outcomes(thisThetaVal, thisSample) == IND_PARADOXICAL;
            end
            
            if thetas(thisThetaVal, thisSample) > .5
                correct2(thisThetaVal, thisSample) = outcomes(thisThetaVal, thisSample) == IND_FAMILIAR;
            else
                correct2(thisThetaVal, thisSample) = outcomes(thisThetaVal, thisSample) == IND_PARADOXICAL;
            end
        else
            correct(thisThetaVal, thisSample) = -1;
        end
    end
end

mean(mean(correct(correct > -1)))
mean(mean(correct2(correct2 > -1)))

thetas = reshape(thetas, [nThetaVals * nSamplesPerVal 1]);
ys = reshape(ys, [nThetaVals * nSamplesPerVal 1]);
xs = reshape(xs, [nThetaVals * nSamplesPerVal 1]);
outcomes = reshape(outcomes, [nThetaVals * nSamplesPerVal 1]);
ys(ys > 10) = NaN;
xs(xs > 10) = NaN;

%% Plot
hold on
[trange, xrange] = meshgrid(.01:.01:.99, 0:.1:10);
yrange = (trange .* xrange) ./ (1 - trange);
yrange(yrange > 10) = NaN;
surf(trange, xrange, yrange);
scatter3(thetas, xs, ys, 5, outcomes);
xlabel('theta');
ylabel('r(p:s)');
zlabel('r(c:sp)');
zlim([0 10]);