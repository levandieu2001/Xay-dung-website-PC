// ========= Thanh tìm kiếm toàn cục (UC04) ==========
function doGlobalSearch() {
  var input = document.getElementById("navSearchInput");
  if (!input) return;
  var kw = input.value.trim();
  if (kw.length > 0) {
    window.location.href = "Products.aspx?q=" + encodeURIComponent(kw);
  } else {
    window.location.href = "Products.aspx";
  }
}

// ========= Chuyển ảnh Banner Slider trên Trang chủ ==========
var slides = document.querySelectorAll(".img-all img");
var dots = document.querySelectorAll(".dot");
var currentIndex = 0;

function updateSlide() {
  if (slides.length === 0) return;
  var translateXValue = currentIndex * -100;
  slides.forEach(function (slide) {
    slide.style.transform = "translateX(" + translateXValue + "%)";
  });
  if (dots.length > 0) {
    dots.forEach(function (dot) {
      dot.classList.remove("active");
    });
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
  var slideInterval = setInterval(nextSlide, 4000);
  dots.forEach(function (dot, index) {
    dot.addEventListener("click", function () {
      currentIndex = index;
      updateSlide();
      clearInterval(slideInterval);
      slideInterval = setInterval(nextSlide, 4000);
    });
  });
}

// ========= Cập nhật số lượng giỏ hàng trên icon navbar (Huy hiệu tròn màu đỏ số trắng) ==========
function updateNavCartCount(newCount) {
  var badge = document.getElementById("navCartBadge");
  if (badge) {
    badge.innerText = newCount;
    if (newCount > 0) {
      badge.style.display = "flex";
      badge.classList.remove("has-items");
      void badge.offsetWidth;
      badge.classList.add("has-items");
    } else {
      badge.style.display = "none";
    }
  }

  var cartBtns = document.querySelectorAll(".nav-btn-cart, a[href='Cart.aspx'] button");
  cartBtns.forEach(function (btn) {
    btn.classList.add("cart-bounce");
    setTimeout(function () {
      btn.classList.remove("cart-bounce");
    }, 450);
  });
}

// ========= Thêm vào giỏ hàng AJAX (Không chuyển trang, không popup thông báo làm phiền) ==========
function addToCartAjax(productId, qty, e) {
  if (e) {
    if (typeof e.preventDefault === "function") e.preventDefault();
    if (typeof e.stopPropagation === "function") e.stopPropagation();
  }
  qty = qty || 1;

  var targetBtn = e && e.currentTarget ? e.currentTarget : null;
  if (targetBtn) {
    targetBtn.style.opacity = "0.7";
  }

  fetch("Cart.aspx?action=add&id=" + productId + "&qty=" + qty + "&ajax=1", {
    headers: { "X-Requested-With": "XMLHttpRequest" }
  })
    .then(function (response) {
      return response.json();
    })
    .then(function (data) {
      if (targetBtn) {
        targetBtn.style.opacity = "1";
      }
      if (data && data.success) {
        // Chỉ cập nhật chấm đỏ trên icon giỏ hàng, hoàn toàn không hiện thông báo nổi
        updateNavCartCount(data.cartCount);
      }
    })
    .catch(function (err) {
      if (targetBtn) {
        targetBtn.style.opacity = "1";
      }
      console.error("Lỗi thêm giỏ hàng:", err);
    });
}


// ========= Slider Flash Deal trên Trang chủ (Tự động lướt & Bấm nút qua lại) ==========
(function initDealSlider() {
  function setupSlider() {
    var track = document.getElementById("dealTrack");
    var viewport = document.getElementById("dealViewport");
    var prevBtn = document.getElementById("dealPrevBtn");
    var nextBtn = document.getElementById("dealNextBtn");
    var container = document.getElementById("dealSliderContainer");

    if (!track || !viewport || !prevBtn || !nextBtn) return;

    var currentOffset = 0;
    var cardStep = 250; // card width (236px) + gap (14px)
    var autoTimer = null;

    function getMaxOffset() {
      var max = track.scrollWidth - viewport.clientWidth;
      return max > 0 ? max : 0;
    }

    function applyOffset(offset) {
      track.style.transform = "translateX(-" + offset + "px)";
    }

    function goNext() {
      var maxOffset = getMaxOffset();
      if (maxOffset <= 0) return;
      currentOffset += cardStep;
      if (currentOffset > maxOffset + 30) {
        currentOffset = 0;
      } else if (currentOffset > maxOffset) {
        currentOffset = maxOffset;
      }
      applyOffset(currentOffset);
    }

    function goPrev() {
      var maxOffset = getMaxOffset();
      if (maxOffset <= 0) return;
      currentOffset -= cardStep;
      if (currentOffset < -10) {
        currentOffset = maxOffset;
      } else if (currentOffset < 0) {
        currentOffset = 0;
      }
      applyOffset(currentOffset);
    }

    nextBtn.onclick = function (e) {
      if (e) { e.preventDefault(); e.stopPropagation(); }
      goNext();
      restartTimer();
    };

    prevBtn.onclick = function (e) {
      if (e) { e.preventDefault(); e.stopPropagation(); }
      goPrev();
      restartTimer();
    };

    function startTimer() {
      stopTimer();
      autoTimer = setInterval(goNext, 3500);
    }

    function stopTimer() {
      if (autoTimer) {
        clearInterval(autoTimer);
        autoTimer = null;
      }
    }

    function restartTimer() {
      stopTimer();
      startTimer();
    }

    if (container) {
      container.onmouseenter = stopTimer;
      container.onmouseleave = startTimer;
    }

    startTimer();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", setupSlider);
  } else {
    setupSlider();
  }
})();

// ========= Tăng / Giảm số lượng (+ -) ==========
function changeQty(inputId, delta, min, max) {
  var input = document.getElementById(inputId);
  if (!input) return;
  var currentVal = parseInt(input.value) || 1;
  var newVal = currentVal + delta;
  if (min !== undefined && newVal < min) newVal = min;
  if (max !== undefined && newVal > max) newVal = max;
  input.value = newVal;
  var evt = new Event("change", { bubbles: true });
  input.dispatchEvent(evt);
}

// ========= Tự động gợi ý tìm kiếm thông minh (Live Search Suggestion) ==========
(function initSearchAutocomplete() {
  function setup() {
    var searchInput = document.getElementById("navSearchInput");
    if (!searchInput) return;

    var container = searchInput.parentElement;
    if (container) {
      container.style.position = "relative";
    }

    var dropdown = document.getElementById("navSearchDropdown");
    if (!dropdown) {
      dropdown = document.createElement("div");
      dropdown.id = "navSearchDropdown";
      dropdown.className = "nav-search-dropdown";
      dropdown.style.display = "none";
      container.appendChild(dropdown);
    }

    var debounceTimer = null;
    var currentKeyword = "";
    var selectedIndex = -1;

    function closeDropdown() {
      dropdown.style.display = "none";
      dropdown.innerHTML = "";
      selectedIndex = -1;
    }

    function renderSuggestions(data) {
      if (!data || !data.results || data.results.length === 0) {
        dropdown.innerHTML = 
          '<div class="nav-search-header"><span>Gợi ý tìm kiếm</span></div>' +
          '<div class="nav-search-empty">Không tìm thấy sản phẩm nào khớp với "<strong>' + escapeHtml(data.keyword || "") + '</strong>"</div>';
        dropdown.style.display = "block";
        selectedIndex = -1;
        return;
      }

      selectedIndex = -1;

      var html = '<div class="nav-search-header">';
      html += '<span><i class="fa-solid fa-magnifying-glass" style="margin-right:5px; color:#697EE9;"></i>Sản phẩm gợi ý (' + data.results.length + ')</span>';
      html += '<span style="font-size:11px; text-transform:none; color:#94a3b8;">Nhấn Enter để tìm</span>';
      html += '</div>';

      data.results.forEach(function (p, idx) {
        html += '<a href="ProductDetail.aspx?id=' + p.id + '" class="nav-search-item" data-index="' + idx + '">';
        html += '<img src="' + escapeHtml(p.imageUrl) + '" alt="' + escapeHtml(p.name) + '" class="nav-search-thumb" onerror="this.src=\'./anh pc/lap1.jpg\';" />';
        html += '<div class="nav-search-info">';
        html += '<div class="nav-search-title" title="' + escapeHtml(p.name) + '">' + escapeHtml(p.name) + '</div>';
        html += '<div class="nav-search-meta">';
        html += '<span class="nav-search-cat">' + escapeHtml(p.category) + '</span>';
        if (p.brand) {
          html += '<span style="color:#64748b; font-size:11.5px;">• ' + escapeHtml(p.brand) + '</span>';
        }
        html += '</div>';
        html += '</div>';
        html += '<div class="nav-search-price-col">';
        html += '<div class="nav-search-price">' + escapeHtml(p.priceFormatted) + '</div>';
        if (p.oldPriceFormatted) {
          html += '<div class="nav-search-oldprice">' + escapeHtml(p.oldPriceFormatted) + '</div>';
        }
        html += '</div>';
        html += '</a>';
      });

      html += '<a href="Products.aspx?q=' + encodeURIComponent(data.keyword) + '" class="nav-search-footer">';
      html += '<i class="fa-solid fa-arrow-right-long" style="margin-right:6px;"></i>Xem tất cả <strong>' + data.total + '</strong> kết quả cho "' + escapeHtml(data.keyword) + '" →';
      html += '</a>';

      dropdown.innerHTML = html;
      dropdown.style.display = "block";
    }

    function fetchSuggestions(kw) {
      if (!kw || kw.length < 1) {
        closeDropdown();
        return;
      }
      fetch("SearchSuggest.ashx?q=" + encodeURIComponent(kw))
        .then(function (res) { return res.json(); })
        .then(function (data) {
          if (searchInput.value.trim() === kw) {
            renderSuggestions(data);
          }
        })
        .catch(function (err) {
          console.error("Lỗi tìm kiếm gợi ý:", err);
        });
    }

    function escapeHtml(str) {
      if (!str) return "";
      return String(str)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
    }

    searchInput.addEventListener("input", function () {
      var kw = this.value.trim();
      if (kw === currentKeyword) return;
      currentKeyword = kw;
      clearTimeout(debounceTimer);
      if (kw.length === 0) {
        closeDropdown();
        return;
      }
      debounceTimer = setTimeout(function () {
        fetchSuggestions(kw);
      }, 200);
    });

    searchInput.addEventListener("focus", function () {
      var kw = this.value.trim();
      if (kw.length > 0) {
        fetchSuggestions(kw);
      }
    });

    searchInput.addEventListener("keydown", function (e) {
      if (dropdown.style.display === "none") return;

      var items = dropdown.querySelectorAll(".nav-search-item");
      if (items.length === 0) return;

      if (e.key === "ArrowDown") {
        e.preventDefault();
        selectedIndex++;
        if (selectedIndex >= items.length) selectedIndex = 0;
        updateHighlight(items);
      } else if (e.key === "ArrowUp") {
        e.preventDefault();
        selectedIndex--;
        if (selectedIndex < 0) selectedIndex = items.length - 1;
        updateHighlight(items);
      } else if (e.key === "Enter") {
        if (selectedIndex >= 0 && items[selectedIndex]) {
          e.preventDefault();
          items[selectedIndex].click();
        }
      } else if (e.key === "Escape") {
        closeDropdown();
      }
    });

    function updateHighlight(items) {
      items.forEach(function (el, idx) {
        if (idx === selectedIndex) {
          el.classList.add("selected");
          el.scrollIntoView({ block: "nearest" });
        } else {
          el.classList.remove("selected");
        }
      });
    }

    document.addEventListener("click", function (e) {
      if (container && !container.contains(e.target)) {
        closeDropdown();
      }
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", setup);
  } else {
    setup();
  }
})();