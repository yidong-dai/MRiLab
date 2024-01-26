
function [rfAmp,rfPhase,rfFreq,rfCoil,rfTime]=rfSinc(p)
%create a sinc rf pulse starting from tStart and ending at tEnd
%tStart rf start time
%tEnd rf end time
%FA rf actual flip angle
%dt rf sample time
%TBP time-bandwidth product
%Apod apodization flag
%rfPhase rf phase
%rfFreq rf off-res freq

tStart=p.tStart;
tEnd=p.tEnd;
FA=p.FA;
dt=p.dt;
rfPhase=p.rfPhase;
rfFreq=p.rfFreq;
rfCoil=p.CoilID;
TBP=p.TBP;
Apod=p.Apod;
Duplicates=max(1,p.Duplicates);
DupSpacing=max(0,p.DupSpacing);

switch Apod % Apodization
    case 'Non' % non
        a=0;
    case 'Hamming' % Hamming
        a=0.46;
    case 'Hanning' % Hanning
        a=0.5;
end

rfTime=linspace(tStart,tEnd,ceil((tEnd-tStart)/dt)+1);
rfTime=rfTime-(tEnd-tStart)/2-tStart;
t0=(tEnd-tStart)/TBP;
rfAmp=((t0*sin(pi*rfTime/t0))./(pi*rfTime)).*((1-a)+a*cos((pi*rfTime)/(TBP*t0)));
rfAmp(isnan(rfAmp))=max(rfAmp);
rfAmp(1)=0;
rfAmp(end)=0;
rfAmp=DoB1Scaling(rfAmp,dt,FA)*rfAmp; %B1 Scaling
rfTime=rfTime+(tEnd-tStart)/2+tStart;

rfPhase=(rfPhase)*ones(size(rfTime));
rfFreq=(rfFreq)*ones(size(rfTime));
rfCoil=(rfCoil)*ones(size(rfTime));
rfPhase(1)=0;
rfPhase(end)=0;
rfFreq(1)=0;
rfFreq(end)=0;

% Create Duplicates
if Duplicates~=1 & DupSpacing ~=0
    rfAmp=repmat(rfAmp,[1 Duplicates]);
    rfFreq=repmat(rfFreq,[1 Duplicates]);
    rfPhase=repmat(rfPhase,[1 Duplicates]);
    rfCoil=repmat(rfCoil,[1 Duplicates]);
    TimeOffset = repmat(0:DupSpacing:(Duplicates-1)*DupSpacing,[length(rfTime) 1]);
    rfTime=repmat(rfTime,[1 Duplicates]) + (TimeOffset(:))';
end

end