const express = require('express');
const cors = require('cors');
const axios = require('axios');
const xml2js = require('xml2js');
const iconv = require('iconv-lite');
const bodyParser = require('body-parser');
const http = require('http');
const { v4: uuidv4 } = require('uuid');

const app = express();
const port = 4000;

const wishlistBackendBaseUrl = 'URL';

app.use(express.json());
app.use(cors());
app.use(bodyParser.json());

let messages = []; // 'send-message' 엔드포인트에서 사용될 메시지 배열

// '/wishlist' 엔드포인트 처리
app.post('/wishlist', async (req, res) => {
  let keyword;
  if (req.body.name) {
    keyword = req.body.name;
    console.log('Received request from NUGU:', keyword);
  } else if (req.body.message) {
    try {
      // 'wishlist' 키에 해당하는 값을 JSON 문자열로 파싱합니다.
      const wishlistObject = JSON.parse(req.body.message);
      console.log('Parsed wishlist object:', wishlistObject);

      // 파싱된 객체에서 'wishlist' 키의 값을 keyword로 사용합니다.
      keyword = wishlistObject['wishlist'];
      console.log('Searching for product with keyword:', keyword);
  } catch (error) {
      console.error('Error processing the request:', error);
      return res.status(400).send('Invalid request format');
  }
  } else {
    console.log('Unexpected request format:', req.body);
    return res.status(400).send('Unexpected request format');
  }

  const apiKey = 'Your API KEY'; // 11번가 API 키를 여기에 입력하세요.
  try {
    const response = await axios.get(`http://openapi.11st.co.kr/openapi/OpenApiService.tmall?key=${apiKey}&apiCode=ProductSearch&keyword=${encodeURIComponent(keyword)}&option=Categories`, {responseType: 'arraybuffer'});
    console.log('Received response from 11st API');

    const decodedString = iconv.decode(Buffer.from(response.data), 'EUC-KR');
    xml2js.parseString(decodedString, { explicitArray: false }, async (err, result) => {
      if (err) {
        console.error('XML Parsing Error:', err);
        return res.status(500).json({ error: 'Error occurred while parsing XML' });
      }

      const product = result.ProductSearchResponse.Products.Product[0] || null;
      if (product) {
        console.log('Product found:', product.ProductName);
        const formattedProduct = {
          id: product.ProductCode,
          image: product.ProductImage100,
          name: product.ProductName,
          detailUrl: product.DetailPageUrl,
        };

        const wishlistBackendUrl = 'URL/wishlist';
        const wishlistResponse = await axios.post(wishlistBackendUrl, formattedProduct);
        console.log('Product sent to wishlist backend:', wishlistResponse.data);

        res.json({ message: 'Product data sent successfully to the wishlist backend.', data: wishlistResponse.data });
      } else {
        console.log('No products found for keyword:', keyword);
        res.status(404).json({ error: 'No products found' });
      }
    });
  } catch (error) {
    console.error('Error fetching product data:', error);
    res.status(500).json({ error: 'Error occurred while fetching product data' });
  }
});

// '/send-message' 엔드포인트 처리
app.post('/send-message', (req, res) => {
  const messageContent = req.body;
  const messageId = uuidv4(); // UUID 생성하여 메시지 ID 할당
  const message = { id: messageId, ...messageContent }; // 메시지 객체에 ID 포함

  console.log('Received message:', message);

  messages.push(message);
  const postData = JSON.stringify(message);

  const options = {
    hostname: 'URL',
    port: 3001,
    path: '/receive-message',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(postData)
    }
  };

  const request = http.request(options, (response) => {
    let responseBody = '';
    response.on('data', (chunk) => {
      responseBody += chunk;
    });
    response.on('end', () => {
      console.log(`Message forwarded with status code: ${response.statusCode}, response: ${responseBody}`);
      res.status(200).send('Message forwarded successfully');
    });
  });

  request.on('error', (error) => {
    console.error('Error while forwarding message:', error);
    res.status(500).send('Error while forwarding message');
  });

  request.write(postData);
  request.end();
});

// 메시지 조회를 위한 '/messages' 엔드포인트 추가
app.get('/messages', (req, res) => {
  res.status(200).json(messages);
});

// 서버 시작
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
