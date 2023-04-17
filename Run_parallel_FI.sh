



START=0
END=5

for (( i=${START}; i<=${END}; i++ )); do
   CUDA_VISIBLE_DEVICES=0 python Inference_FI_weights.py --checkpoint split5 --pretrained --warmup --config configs/split5_faulty${i}.yaml --resume split5/model_best.pth.tar &
done