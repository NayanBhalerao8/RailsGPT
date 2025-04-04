// AI Commentary integration for blog content with streaming support
document.addEventListener('turbo:load', function() {
  initAiCommentary();
});

document.addEventListener('DOMContentLoaded', function() {
  initAiCommentary();
});

function initAiCommentary() {
  console.log('Initializing AI Commentary integration with streaming');
  
  const contentTextarea = document.getElementById('blog_post_content');
  const generateCommentaryButton = document.getElementById('generate_commentary');
  const commentaryContainer = document.getElementById('ai-commentary-container');
  const commentaryContent = document.getElementById('ai-commentary-content');
  const commentaryLoading = document.getElementById('ai-commentary-loading');
  
  // Track if we have an active stream
  let activeStream = null;
  
  if (contentTextarea && generateCommentaryButton && commentaryContainer && commentaryContent) {
    console.log('Found AI commentary elements, setting up event listeners');
    
    // Function to handle regular commentary generation
    function generateRegularCommentary() {
      const content = contentTextarea.value.trim();
      
      if (content.length < 20) {
        commentaryContainer.style.display = 'block';
        commentaryContent.textContent = 'Please add more content (at least 20 characters) to receive AI feedback.';
        return;
      }
      
      // Show loading state
      commentaryContainer.style.display = 'block';
      commentaryContent.style.display = 'none';
      commentaryLoading.style.display = 'block';
      
      // Get CSRF token from meta tag
      const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
      
      // Send request to generate commentary
      fetch('/blog_posts/generate_commentary', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken
        },
        body: JSON.stringify({ content: content })
      })
      .then(response => {
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        return response.json();
      })
      .then(data => {
        // Hide loading state
        commentaryLoading.style.display = 'none';
        commentaryContent.style.display = 'block';
        
        // Display the commentary
        commentaryContent.textContent = data.commentary;
      })
      .catch(error => {
        console.error('Error generating commentary:', error);
        
        // Hide loading state
        commentaryLoading.style.display = 'none';
        commentaryContent.style.display = 'block';
        
        // Display error message
        commentaryContent.textContent = 'Sorry, there was an error generating feedback. Please try again later.';
      });
    }
    
    // Function to handle streaming commentary generation
    function generateStreamingCommentary() {
      const content = contentTextarea.value.trim();
      
      if (content.length < 20) {
        commentaryContainer.style.display = 'block';
        commentaryContent.textContent = 'Please add more content (at least 20 characters) to receive AI feedback.';
        return;
      }
      
      // Close any existing stream
      if (activeStream) {
        activeStream.close();
        activeStream = null;
      }
      
      // Show loading state
      commentaryContainer.style.display = 'block';
      commentaryContent.style.display = 'block';
      commentaryLoading.style.display = 'block';
      commentaryContent.textContent = 'Analyzing your text...';
      
      // Create a new EventSource for streaming
      const encodedContent = encodeURIComponent(content);
      activeStream = new EventSource(`/blog_posts/stream_commentary?content=${encodedContent}`);
      
      // Handle incoming messages
      activeStream.onmessage = function(event) {
        // Hide loading state once we start receiving data
        commentaryLoading.style.display = 'none';
        
        if (event.data === '[DONE]') {
          // Stream is complete
          activeStream.close();
          activeStream = null;
          return;
        }
        
        try {
          // Update the commentary content with the streamed data
          commentaryContent.textContent = JSON.parse(event.data);
        } catch (error) {
          console.error('Error parsing stream data:', error);
        }
      };
      
      // Handle errors
      activeStream.onerror = function(error) {
        console.error('Stream error:', error);
        commentaryLoading.style.display = 'none';
        commentaryContent.textContent = 'Sorry, there was an error with the streaming connection. Please try again.';
        
        // Close the stream on error
        activeStream.close();
        activeStream = null;
      };
    }
    
    // Button click handler - use streaming if supported, otherwise fallback to regular
    generateCommentaryButton.addEventListener('click', function(e) {
      e.preventDefault();
      
      // Check if EventSource is supported by the browser
      if (typeof EventSource !== 'undefined') {
        generateStreamingCommentary();
      } else {
        // Fallback for browsers that don't support EventSource
        generateRegularCommentary();
      }
    });
    
    // Add event listener to textarea for real-time updates (debounced)
    let debounceTimer;
    let lastContent = '';
    
    contentTextarea.addEventListener('input', function() {
      clearTimeout(debounceTimer);
      
      debounceTimer = setTimeout(function() {
        const content = contentTextarea.value.trim();
        
        // Only trigger if content has significantly changed (at least 20 chars and 25% different)
        if (content.length >= 20 && isContentSignificantlyChanged(content, lastContent)) {
          lastContent = content;
          
          // Use streaming if available
          if (typeof EventSource !== 'undefined') {
            generateStreamingCommentary();
          } else {
            generateRegularCommentary();
          }
        }
      }, 1500); // Wait 1.5 seconds after typing stops
    });
    
    // Helper function to determine if content has changed significantly
    function isContentSignificantlyChanged(newContent, oldContent) {
      // If no previous content or commentary not yet shown, consider it changed
      if (!oldContent || commentaryContainer.style.display !== 'block') {
        return true;
      }
      
      // If length difference is more than 25%, consider it changed
      const lengthDiff = Math.abs(newContent.length - oldContent.length);
      const lengthThreshold = oldContent.length * 0.25;
      
      return lengthDiff > lengthThreshold;
    }
    
    // Clean up event source when navigating away
    window.addEventListener('beforeunload', function() {
      if (activeStream) {
        activeStream.close();
        activeStream = null;
      }
    });
  } else {
    console.log('AI commentary elements not found', { 
      contentTextarea: contentTextarea ? 'found' : 'not found', 
      generateCommentaryButton: generateCommentaryButton ? 'found' : 'not found',
      commentaryContainer: commentaryContainer ? 'found' : 'not found',
      commentaryContent: commentaryContent ? 'found' : 'not found'
    });
  }
}
