#!/bin/bash

npm install
npm run build
aws s3 sync build/ s3://www.deepvision.sg --acl public-read