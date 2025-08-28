import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool showMessage;
  final bool useShimmer;
  
  const LoadingWidget({
    super.key, 
    this.message,
    this.showMessage = true,
    this.useShimmer = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useShimmer) {
      return _buildShimmerLoading(context);
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (showMessage && message != null) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) => _buildShimmerCard(context),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Leading circle
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Container(
                        height: 16,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      
                      // Subtitle
                      Container(
                        height: 12,
                        width: 120,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      
                      // Chips
                      Row(
                        children: [
                          Container(
                            height: 24,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 24,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Trailing
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
