clc
clear all
close all

%% Verificar se há dados faltantes
dataset = readmatrix('dataset_vogais.xlsx');
sum(ismissing(dataset))

dataset = dataset(:, 1:3);

%% Feature Scaling -> Standardisation: resultado entre -3 e +3

dataset(:,1) = (dataset(:,1)-mean(dataset(:,1))/std(dataset(:,1)));
dataset(:,2) = (dataset(:,2)-mean(dataset(:,2))/std(dataset(:,2)));
dataset(:,3) = (dataset(:,3)-mean(dataset(:,3))/std(dataset(:,3)));

%% Knn

%idx = kmeans(dataset, 5);
%figure(1)
%gscatter(dataset(:,2), dataset(:,3), idx)
%legend('Vogal /a/', 'Vogal /e/', 'Vogal /i/', 'Vogal /o/', 'Vogal /u/')
%grid

% ta bem ruim

%% Knn
%% https://www.youtube.com/watch?v=9m8hy5-HauY&ab_channel=KnowledgeAmplifier
%% modelformed = fitcknn(datasetvogais, 'vogal~f1+f2');
%% modelformed
%% modelformed.NumNeighbors=10;
%% predict(modelformed, [663.59,2589.86])







