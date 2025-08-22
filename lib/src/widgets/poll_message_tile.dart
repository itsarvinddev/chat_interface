import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/chat_theme.dart';

/// A widget that displays a poll in a chat message with voting interface
class PollMessageTile extends StatefulWidget {
  /// The poll to display
  final Poll poll;

  /// Whether this poll is from the current user
  final bool isFromCurrentUser;

  /// Current user ID for voting logic
  final String currentUserId;

  /// Called when user votes on the poll
  final void Function(String pollId, List<String> optionIds)? onVote;

  /// Called when user wants to view detailed results
  final void Function(Poll poll)? onViewResults;

  /// Whether to show detailed results instead of voting interface
  final bool showResults;

  /// Theme configuration
  final ChatThemeData? theme;

  const PollMessageTile({
    super.key,
    required this.poll,
    required this.currentUserId,
    this.isFromCurrentUser = false,
    this.onVote,
    this.onViewResults,
    this.showResults = false,
    this.theme,
  });

  @override
  State<PollMessageTile> createState() => _PollMessageTileState();
}

class _PollMessageTileState extends State<PollMessageTile> {
  final Set<String> _selectedOptions = <String>{};
  bool _isVoting = false;

  @override
  void initState() {
    super.initState();
    // Initialize with current user's votes
    _selectedOptions.addAll(widget.poll.currentUserVotes.map((o) => o.id));
  }

  void _toggleOption(String optionId) {
    if (widget.poll.hasEnded) return;

    setState(() {
      if (widget.poll.type == PollType.singleChoice) {
        _selectedOptions.clear();
        _selectedOptions.add(optionId);
        _submitVote(); // Auto-submit for single choice
      } else {
        if (_selectedOptions.contains(optionId)) {
          _selectedOptions.remove(optionId);
        } else {
          // Check max selections limit
          if (widget.poll.maxSelections != null &&
              _selectedOptions.length >= widget.poll.maxSelections!) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'You can select up to ${widget.poll.maxSelections} options',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
            return;
          }
          _selectedOptions.add(optionId);
        }
      }
    });
  }

  void _submitVote() {
    if (_selectedOptions.isEmpty || widget.onVote == null) return;

    setState(() => _isVoting = true);

    widget.onVote!(widget.poll.id, _selectedOptions.toList());

    // Simulate voting delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _isVoting = false);
        }
      });
    });
  }

  Color _getOptionColor(PollOption option) {
    final themeData =
        widget.theme ?? ChatThemeData.fromTheme(Theme.of(context));

    if (option.isVotedByCurrentUser) {
      return widget.isFromCurrentUser
          ? themeData.outgoingBubbleColor
          : themeData.incomingBubbleColor;
    }

    return Colors.grey[100]!;
  }

  Widget _buildPollHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.poll, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              'Poll',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (widget.poll.hasEnded)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Ended',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else if (widget.poll.deadline != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatTimeRemaining(),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.poll.question,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildOption(PollOption option) {
    final hasVoted = widget.poll.hasCurrentUserVoted || widget.poll.hasEnded;
    final isSelected = _selectedOptions.contains(option.id);
    final percentage = widget.poll.totalVotes > 0
        ? (option.voteCount / widget.poll.totalVotes * 100)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: widget.poll.hasEnded ? null : () => _toggleOption(option.id),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getOptionColor(option),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: option.isVotedByCurrentUser
                  ? (widget.isFromCurrentUser ? Colors.white : Colors.blue)
                  : (isSelected ? Colors.blue : Colors.grey[300]!),
              width: option.isVotedByCurrentUser || isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Selection indicator
                  if (widget.poll.type == PollType.singleChoice)
                    Icon(
                      option.isVotedByCurrentUser
                          ? Icons.radio_button_checked
                          : (isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked),
                      size: 20,
                      color: option.isVotedByCurrentUser
                          ? (widget.isFromCurrentUser
                                ? Colors.white
                                : Colors.blue)
                          : (isSelected ? Colors.blue : Colors.grey[600]),
                    )
                  else
                    Icon(
                      option.isVotedByCurrentUser
                          ? Icons.check_box
                          : (isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank),
                      size: 20,
                      color: option.isVotedByCurrentUser
                          ? (widget.isFromCurrentUser
                                ? Colors.white
                                : Colors.blue)
                          : (isSelected ? Colors.blue : Colors.grey[600]),
                    ),
                  const SizedBox(width: 12),

                  // Option text
                  Expanded(
                    child: Text(
                      option.text,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            option.isVotedByCurrentUser &&
                                widget.isFromCurrentUser
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: option.isVotedByCurrentUser
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),

                  // Vote count and percentage
                  if (hasVoted || widget.showResults) ...[
                    Text(
                      '${option.voteCount}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            option.isVotedByCurrentUser &&
                                widget.isFromCurrentUser
                            ? Colors.white70
                            : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color:
                            option.isVotedByCurrentUser &&
                                widget.isFromCurrentUser
                            ? Colors.white70
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),

              // Progress bar
              if ((hasVoted || widget.showResults) &&
                  widget.poll.totalVotes > 0) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor:
                        option.isVotedByCurrentUser && widget.isFromCurrentUser
                        ? Colors.white30
                        : Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      option.isVotedByCurrentUser && widget.isFromCurrentUser
                          ? Colors.white
                          : Colors.blue,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPollStats() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.how_to_vote, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${widget.poll.totalVotes} ${widget.poll.totalVotes == 1 ? 'vote' : 'votes'}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              if (widget.poll.totalVoters != widget.poll.totalVotes) ...[
                Text(
                  ' • ${widget.poll.totalVoters} ${widget.poll.totalVoters == 1 ? 'voter' : 'voters'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
              const Spacer(),
              if (widget.poll.type == PollType.multipleChoice)
                Text(
                  'Multiple choice',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),

          // Action buttons
          if (!widget.poll.hasEnded) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (widget.poll.type == PollType.multipleChoice &&
                    _selectedOptions.isNotEmpty)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isVoting ? null : _submitVote,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: _isVoting
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text('Vote (${_selectedOptions.length})'),
                    ),
                  ),

                if (widget.onViewResults != null &&
                    widget.poll.hasCurrentUserVoted) ...[
                  if (widget.poll.type == PollType.multipleChoice &&
                      _selectedOptions.isNotEmpty)
                    const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => widget.onViewResults!(widget.poll),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('View Results'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimeRemaining() {
    if (widget.poll.deadline == null) return '';

    final now = DateTime.now();
    final deadline = widget.poll.deadline!;

    if (now.isAfter(deadline)) return 'Ended';

    final difference = deadline.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m left';
    } else {
      return 'Ending soon';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData =
        widget.theme ?? ChatThemeData.fromTheme(Theme.of(context));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isFromCurrentUser
            ? themeData.outgoingBubbleColor
            : themeData.incomingBubbleColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPollHeader(),
          const SizedBox(height: 16),
          ...widget.poll.options.map(_buildOption),
          _buildPollStats(),
        ],
      ),
    );
  }
}
