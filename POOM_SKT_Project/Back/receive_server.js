// 필요한 라이브러리를 불러옵니다.
const express = require('express'); // Express 웹 프레임워크
const bodyParser = require('body-parser'); // 요청 본문을 파싱하는 미들웨어

// Express 애플리케이션 인스턴스를 생성합니다.
const app = express();
app.use(express.json()); // JSON 형식의 본문을 파싱할 수 있게 설정합니다.
const port = 3001; // 이 서버의 포트 번호, 다른 서버와 구분하기 위해 다른 포트 번호를 사용1

// 저장된 제품 정보를 관리할 배열을 초기화합니다.
let products = [];
let calendarMessages = [];
let greetingMessages = [];
let savedMessages = [];
// 미들웨어를 사용하여 JSON 형태의 요청 본문을 파싱합니다.
app.use(bodyParser.json());

// '/wishlist' 경로로 들어오는 POST 요청을 처리합니다. 이 요청은 새로운 제품 정보를 저장합니다.
app.post('/wishlist', (req, res) => {
  const product = req.body; // 요청 본문에서 제품 정보를 추출합니다.
  console.log('Received product:', product); // 서버 콘솔에 받은 제품 정보를 로깅합니다.

  // 중복된 제품이 없는 경우에만 제품을 배열에 추가합니다.
  if (!products.find(p => p.id === product.id)) {
    products.push(product); // 제품 배열에 제품을 추가합니다.
    console.log('Product added to wishlist:', product); // 제품 추가 사실을 로깅합니다.
    // 클라이언트에 성공 메시지를 응답합니다.
    res.status(200).json({ message: 'Product added to wishlist successfully', product });
  } else {
    // 이미 같은 ID의 제품이 존재하는 경우 에러 메시지를 응답합니다.
    res.status(400).json({ message: 'Product already exists in wishlist' });
  }
});

// '/wishlist' 경로로 들어오는 GET 요청을 처리합니다. 이 요청은 저장된 모든 제품 정보를 제공합니다.
app.get('/wishlist', (req, res) => {
  console.log('Fetching all products from wishlist'); // 제품 정보 조회 사실을 로깅합니다.
  res.status(200).json(products); // 저장된 모든 제품 정보를 클라이언트에 응답합니다.
});

// '/wishlist/:id' 경로로 들어오는 DELETE 요청을 처리합니다. 이 요청은 특정 ID의 제품을 삭제합니다.
app.delete('/wishlist/:id', (req, res) => {
  const { id } = req.params;
  const index = products.findIndex(product => product.id === id);
  if (index !== -1) {
    products.splice(index, 1);
    res.status(200).json({ message: 'Product removed from wishlist successfully' });
  } else {
    res.status(404).json({ message: 'Product not found' });
  }
});





app.post('/receive-message', (req, res) => {
  const message = req.body; // message는 JSON 문자열
  
  console.log('Received raw message:', message);

  // JSON 문자열을 객체로 파싱

  savedMessages.push(message);  
    // 'shared calendar event' 키가 있는지 확인
    if (message.hasOwnProperty('shared calendar event')) { // 'shared calendar event' 키 확인
      calendarMessages.push(message['shared calendar event']); // 메시지 객체에서 'shared calendar event' 값을 직접 추가
      console.log('Updated calendarMessages:', calendarMessages); // calendarMessages 배열의 내용을 로그로 출력
    } else{
      greetingMessages.push(message);
      console.log('Updated greetingMessages:', greetingMessages); // greetingMessages 배열의 내용을 로그로 출력
    }

  res.status(200).send('Message received successfully');
});


// GET 요청으로 모든 메시지 불러오기
app.get('/receive-message', (req, res) => {
res.status(200).json(savedMessages);
});

// Wishlist 메시지를 불러오는 엔드포인트
app.get('/wishlist', (req, res) => {
res.status(200).json(wishlistMessages);
});

// Calendar 메시지를 불러오는 엔드포인트
app.get('/calendar', (req, res) => {
res.status(200).json(calendarMessages);
});

// Greeting 메시지를 불러오는 엔드포인트
app.get('/greeting', (req, res) => {
res.status(200).json(greetingMessages);
});


app.get('/latest-greeting', (req, res) => {
  if (greetingMessages.length > 0) {
    console.log(greetingMessages.length);

    const latestGreetingMessage = JSON.parse(greetingMessages[greetingMessages.length - 1].message)['greeting message'];
    res.status(200).json(latestGreetingMessage);
  } else {
    res.status(200).json("No greetings yet");
  }
});


app.delete('/delete-message/:id', (req, res) => {
  const { id } = req.params;
  const index = savedMessages.findIndex(event => event.id === id);
  if (index !== -1) {
    savedMessages.splice(index, 1);
    res.status(200).send({ message: 'Event deleted successfully' });
  } else {
    res.status(404).send({ message: 'Event not found' });
  }
});



app.listen(port, () => {
  console.log(`Wishlist Server is running on http://localhost:${port}`);
});
