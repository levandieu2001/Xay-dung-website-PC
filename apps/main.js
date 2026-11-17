// ========= chuyen anh ==========
const slides = document.querySelectorAll(".img-all img");
const dots = document.querySelectorAll(".dot");
let currentIndex = 0;
function updateSlide() {
  if (slides.length === 0) return;
  const translateXValue = currentIndex * -100;
  slides.forEach((slide) => {
    slide.style.transform = `translateX(${translateXValue}%)`;
  });
  if (dots.length > 0) {
    dots.forEach((dot) => dot.classList.remove("active"));
    if (dots[currentIndex]) {
      dots[currentIndex].classList.add("active");
    }
  }
}

function nextSlide() {
  currentIndex++;

  if (currentIndex >= slides.length) {
    currentIndex = 0;
  }
  updateSlide();
}
if (slides.length > 0) {
  let slideInterval = setInterval(nextSlide, 4000);
  dots.forEach((dot, index) => {
    dot.addEventListener("click", () => {
      currentIndex = index;
      updateSlide();

      clearInterval(slideInterval);
      slideInterval = setInterval(nextSlide, 4000);
    });
  });
}

// ==== Kiem Tra =====
const contactForm = document.getElementById("contactForm");

if (contactForm && document.getElementById("fullname")) {
  contactForm.addEventListener("submit", function (e) {
    e.preventDefault();

    const fullname = document.getElementById("fullname").value.trim();
    const phone = document.getElementById("phone").value.trim();
    const email = document.getElementById("email").value.trim();
    const content = document.getElementById("content").value.trim();

    if (fullname === "") {
      alert("Vui lòng nhập Họ và tên của bạn!");
      document.getElementById("fullname").focus();
      return;
    }

    const phoneRegex = /^0\d{9}$/;

    if (phone === "") {
      alert("Vui lòng nhập Số điện thoại!");
      document.getElementById("phone").focus();
      return;
    } else if (!phoneRegex.test(phone)) {
      alert("Số điện thoại không hợp lệ! (Phải có 10 số và bắt đầu bằng số 0)");
      document.getElementById("phone").focus();
      return;
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (email === "") {
      alert("Vui lòng nhập Email!");
      document.getElementById("email").focus();
      return;
    } else if (!emailRegex.test(email)) {
      alert("Email không đúng định dạng! (Ví dụ: abc@gmail.com)");
      document.getElementById("email").focus();
      return;
    }

    if (content === "") {
      alert("Vui lòng nhập Nội dung cần hỗ trợ!");
      document.getElementById("content").focus();
      return;
    }

    alert("Gửi thông tin thành công! Chúng tôi sẽ liên hệ lại sớm nhất.");

    contactForm.reset();
  });
}
