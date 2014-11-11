if [ -e "./result" ]; then
  rm ./result/json/*
else
  mkdir -p result/json result/img
fi

time ruby checkins.rb
